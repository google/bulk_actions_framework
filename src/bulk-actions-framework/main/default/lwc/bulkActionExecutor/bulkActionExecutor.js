/**
 * Copyright 2024 Google LLC
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *     http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

import { LightningElement, api } from "lwc";
import { getConstants } from "c/bulkActionUtil";
import LightningAlert from "lightning/alert";
import getConfig from "@salesforce/apex/BulkActionExecutorController.getConfig";
import getTableDetails from "@salesforce/apex/BulkActionExecutorController.getTableDetails";
import executeEvaluationFlow from "@salesforce/apex/BulkActionExecutorController.executeEvaluationFlow";
import executeActionFlow from "@salesforce/apex/BulkActionExecutorController.executeActionFlow";

//constants
const CONSTANTS = getConstants();

export default class BulkActionExecutor extends LightningElement {
  @api ids;
  @api bulkActionTemplateName;
  @api returnObjectName;

  //display variables
  spinner = false;
  validInputs = false;
  showPreviewScreen = false;
  showInputScreen = false;
  showResultScreen = false;
  showReEvalButton = false;

  //data variables
  config;
  data;
  columns;
  records;
  capturedInputs;
  eligibleRecordCount = 0;
  processedRecordCount = 0;

  //help text variables
  helpText = "";
  helpTextClass = CONSTANTS.HELPTEXT_CSS;

  connectedCallback() {
    //onload, check if required parameters are passed from list view button
    this.validateInputs();
  }

  get previewScreenNextLabel() {
    return this.config.Preview_Screen_Button_Name__c !== undefined
      ? this.config.Preview_Screen_Button_Name__c
      : "Next";
  }

  get showPreviewScreenButton() {
    return this.eligibleRecords.length > 0;
  }

  get eligibleRecordsTableType() {
    return CONSTANTS.TABLE.ELIGIBLE_RECORDS.LABEL;
  }

  get nonEligibleRecordsTableType() {
    return CONSTANTS.TABLE.NON_ELIGIBLE_RECORDS.LABEL;
  }

  get actionRecordsTableType() {
    return CONSTANTS.TABLE.ACTION_RESULT.LABEL;
  }

  get eligibleRecords() {
    let result = [];
    if (!this.records) {
      return result;
    }
    for (const row of this.records) {
      if (row.isValid) {
        result.push(row.displayRecord);
      }
    }
    this.eligibleRecordCount = result.length;
    return result;
  }

  get nonEligibleRecords() {
    let result = [];
    if (!this.records) {
      return result;
    }
    for (const row of this.records) {
      if (!row.isValid) {
        result.push(row.displayRecord);
      }
    }
    return result;
  }

  get results() {
    let rowsAppendedWithResult = [];
    for (const row of this.records) {
      let record = row.displayRecord;
      record[CONSTANTS.ACTION_STATUS_FLD] = row.actionStatus;
      record[CONSTANTS.ACTION_ERR_MSG_FLD] = row.actionErrorMessage;
      rowsAppendedWithResult.push(record);
    }
    this.processedRecordCount = rowsAppendedWithResult.length;
    return rowsAppendedWithResult;
  }

  get getRecordsUpdatedMessage() {
    let message;
    if (
      this.processedRecordCount > 0 &&
      this.eligibleRecordCount !== this.processedRecordCount
    ) {
      message = `Some of the records were updated inbetween transition from preview screen to executing
                        an action. The action results are updated according to the latest record updates to the selected
                        records. Please find the below records on which action is executed.`;
    }
    return message;
  }

  get getNonEligibleRecordsMessage() {
    let message;
    if (this.config.Eval_Flow_Error_Message__c) {
      message = this.config.Eval_Flow_Error_Message__c;
    } else {
      message =
        "Some of the records from selected records does not meet defined action criteria.";
    }
    message += ` You can still execute action for the records meeting criteria
              displayed below.
              If any of the records got updated while you are on this page, you
              can click 'Re-evaluate action criteria' button to get the updated
              records meeting action criteria.`;
    return message;
  }

  get resultColumns() {
    let columns = [];
    if (!this.columns) {
      return columns;
    }
    columns = [...this.columns];
    columns.push({ label: "Action Status", apiName: "actionStatus" });
    return columns;
  }

  /**
   * validates the input parameters, both ids and bulkActionTemplateName are reuired paramenters
   * if any of them is not provided error is displayed
   * if both are provided, getBulkActionConfig() called to get configuration and data for records
   */
  validateInputs() {
    this.spinner = true;
    if (this.validInputs) {
      return;
    }
    if (!this.ids || this.ids === "undefined") {
      this.showToastMessage(
        CONSTANTS.ERROR_MESSAGE.NO_RECORDS_MESSAGE,
        CONSTANTS.ERROR_THEME,
        CONSTANTS.ERROR_TITLE
      );
    } else if (
      !this.bulkActionTemplateName ||
      this.bulkActionTemplateName === "undefined"
    ) {
      this.showToastMessage(
        CONSTANTS.NO_CONFIG_PASSED_MESSAGE,
        CONSTANTS.ERROR_THEME,
        CONSTANTS.ERROR_TITLE
      );
    } else {
      this.validInputs = true;
      this.spinner = false;
      this.getBulkActionConfig();
    }
  }

  /**
   * gets Bulk_Action_Config__mdt record from provided parameter
   * if valid config record found, record details are featched from provided record ids
   */
  getBulkActionConfig() {
    getConfig({ configName: this.bulkActionTemplateName })
      .then((result) => {
        if (result === null) {
          return;
        }
        this.config = result;
        getTableDetails({
          recordIds: this.ids,
          fieldSetName: this.config.Preview_Screen_Field_Set_API_Name__c
        })
          .then((result) => {
            this.data = result;
            this.records = result.rows;
            this.columns = result.columns;
            this.executeFlows();
          })
          .catch((error) => {
            this.showToastMessage(
              this.reduceErrors(error),
              CONSTANTS.ERROR_THEME,
              CONSTANTS.ERROR_TITLE
            );
          });
      })
      .catch((error) => {
        this.showToastMessage(
          this.reduceErrors(error),
          CONSTANTS.ERROR_THEME,
          CONSTANTS.ERROR_TITLE
        );
      });
  }

  /**
   * executes required flow based on custom metadata configuration
   * action flow is required, if not present in custom metadata, error thrown
   * eval flow is optional, if defined, eval flow is called from invocable class
   */
  executeFlows() {
    if (
      //execute eval flow if defined else skip to preview screen with all selected records
      this.config.Eval_Flow_API_Name__c !== undefined
    ) {
      this.executeEvaluationFlow();
      this.showReEvalButton = true;
    } else {
      this.showPreviewScreen = true;
    }
  }

  /** executes evaluation flow and sets the record variable for display on preview screen. */
  executeEvaluationFlow() {
    this.spinner = true;
    executeEvaluationFlow({
      table: this.data,
      evalFlowApiName: this.config.Eval_Flow_API_Name__c
    })
      .then((result) => {
        this.showPreviewScreen = true;
        this.records = result;
      })
      .catch((error) => {
        this.showToastMessage(
          this.reduceErrors(error),
          CONSTANTS.ERROR_THEME,
          CONSTANTS.ERROR_TITLE
        );
      })
      .finally(() => {
        this.spinner = false;
      });
  }

  /** executes action flow and updates the display table with action status and error message if failed.*/
  executeActionFlow() {
    this.showPreviewScreen = false;
    this.showInputScreen = false;
    this.spinner = true;
    const formattedInputs = this.formatInputs(this.capturedInputs);
    executeActionFlow({
      table: this.data,
      config: this.config,
      screenFlowInputs: formattedInputs
    })
      .then((result) => {
        this.records = result;
        this.showResultScreen = true;
        if (this.config.Custom_Success_Message__c) {
          this.showToastMessage(
            this.config.Custom_Success_Message__c,
            CONSTANTS.WARNING_THEME,
            CONSTANTS.WARNING_TITLE
          );
        }
      })
      .catch((error) => {
        this.showToastMessage(
          this.reduceErrors(error),
          CONSTANTS.ERROR_THEME,
          CONSTANTS.ERROR_TITLE
        );
      })
      .finally(() => {
        this.spinner = false;
      });
  }

  formatInputs(capturedInputs) {
    let result = {};
    if (capturedInputs === undefined) {
      return result;
    }
    const captured = JSON.parse(capturedInputs);
    for (let input of captured) {
      result[input.name] = input.value;
    }
    return result;
  }

  handleCancel() {
    let returnURL;
    if (this.data === undefined && this.returnObjectName !== undefined) {
      returnURL = "/lightning/o/" + this.returnObjectName + "/list";
    } else if (this.data === undefined && this.returnObjectName === undefined) {
      returnURL = "/lightning/page/home";
    } else {
      returnURL = this.data.returnURL;
    }
    window.location = returnURL;
  }

  handleNext() {
    this.spinner = true;
    if (this.config.Input_Flow_API_Name__c !== undefined) {
      this.showPreviewScreen = false;
      this.showInputScreen = true;
      this.spinner = false;
    } else {
      this.executeActionFlow();
    }
  }

  handleInputFlowStatusChange(event) {
    if (event.detail.status === "FINISHED") {
      this.capturedInputs = JSON.stringify(event.detail.outputVariables);
      this.executeActionFlow();
    }
  }

  refreshPage() {
    location.reload();
  }

  updateHelpText(event) {
    if (!this.helpText) {
      this.helpText = event.detail.helpText;
    }
  }

  openHelpText() {
    this.helpTextClass = CONSTANTS.HELPTEXT_OPEN_CSS;
  }

  closeHelpText() {
    this.helpTextClass = CONSTANTS.HELPTEXT_CSS;
  }

  reduceErrors(error) {
    return error.body.message;
  }

  showToastMessage(alertMessage, theme, title) {
    this.spinner = false;
    LightningAlert.open({
      message: alertMessage,
      theme: theme,
      label: title
    }).then(() => {
      this.handleCancel();
    });
  }
}
