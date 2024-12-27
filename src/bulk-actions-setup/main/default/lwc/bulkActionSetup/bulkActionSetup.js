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
import LightningAlert from "lightning/alert";
import { getConstants } from "c/bulkActionSetupUtil";
import insertConfig from "@salesforce/apex/BulkActionSetupController.insertConfig";

//constants
const CONSTANTS = getConstants();
const REGEX_IGNORE_NUMBER_ALPHABETS = "[^a-zA-Z0-9]";

export default class BulkActionSetup extends LightningElement {
  @api existingConfig;
  _isFinalStep = false;
  _showPrev = false;
  _showDeploymentLink = false;
  jobId;
  deploymentStatus;
  selectedIndex = 1;
  selectedStep = CONSTANTS.STEPS.STEP1;
  isRestrictedAction = false;
  isEvalFlowRequired = false;
  isInputFlowRequired = false;
  isActionInAsync = false;

  bulkActionName;
  bulkActionObject;
  bulkActionAPIName;
  requiredPermissionName;
  previewFieldSetName;
  previewButtonName;
  evalFlowAPIName;
  evalFlowMessage;
  inputFlowAPIName;
  actionFlowAPIName;
  customMessage;

  connectedCallback() {
    if (this.existingConfig !== undefined) {
      this.loadExistingConfig();
    }
  }

  get isStep1() {
    return this.selectedStep === CONSTANTS.STEPS.STEP1;
  }

  get isStep2() {
    return this.selectedStep === CONSTANTS.STEPS.STEP2;
  }

  get isStep3() {
    return this.selectedStep === CONSTANTS.STEPS.STEP3;
  }

  get isStep4() {
    return this.selectedStep === CONSTANTS.STEPS.STEP4;
  }

  get isStep5() {
    return this.selectedStep === CONSTANTS.STEPS.STEP5;
  }

  get isStep6() {
    return this.selectedStep === CONSTANTS.STEPS.STEP6;
  }

  get isFinalStep() {
    return this._isFinalStep;
  }

  get config() {
    return {
      MasterLabel: this.bulkActionName,
      Action_Flow_API_Name__c: this.actionFlowAPIName,
      Eval_Flow_API_Name__c: this.evalFlowAPIName,
      Eval_Flow_Error_Message__c: this.evalFlowMessage,
      Input_Flow_API_Name__c: this.inputFlowAPIName,
      Preview_Screen_Button_Name__c: this.previewButtonName,
      Preview_Screen_Field_Set_API_Name__c: this.previewFieldSetName,
      Required_Permission__c: this.requiredPermissionName,
      Is_Action_Flow_Execution_in_Async_Mode__c: this.isActionInAsync,
      Custom_Success_Message__c: this.customMessage,
      Object_API_Name__c: this.bulkActionObject
    };
  }

  get configButtonValue() {
    return this.existingConfig === undefined
      ? "Create New Configuration"
      : "Update Configuration";
  }

  get flowDetails() {
    return {
      evalFlow: this.evalFlowAPIName,
      inputFlow: this.inputFlowAPIName,
      actionFlow: this.actionFlowAPIName,
      fieldSet: this.previewFieldSetName,
      bulkActionName: this.bulkActionName,
      bulkActionObject: this.bulkActionObject
    };
  }
  set isFinalStep(value) {
    this._isFinalStep = value;
  }

  get showPrev() {
    return this._showPrev;
  }

  set showPrev(value) {
    this._showPrev = value;
  }

  get isDeploymentLinkVisible() {
    return this._showDeploymentLink;
  }

  set isDeploymentLinkVisible(value) {
    this._showDeploymentLink = value;
  }

  loadExistingConfig() {
    this.bulkActionName = this.existingConfig.MasterLabel;
    this.bulkActionObject = this.existingConfig.Object_API_Name__c;
    this.isRestrictedAction =
      this.existingConfig.Required_Permission__c !== undefined;
    this.isEvalFlowRequired =
      this.existingConfig.Eval_Flow_API_Name__c !== undefined;
    this.isInputFlowRequired =
      this.existingConfig.Input_Flow_API_Name__c !== undefined;
    this.actionFlowAPIName = this.existingConfig.Action_Flow_API_Name__c;
    this.evalFlowAPIName = this.existingConfig.Eval_Flow_API_Name__c;
    this.evalFlowMessage = this.existingConfig.Eval_Flow_Error_Message__c;
    this.inputFlowAPIName = this.existingConfig.Input_Flow_API_Name__c;
    this.previewButtonName = this.existingConfig.Preview_Screen_Button_Name__c;
    this.previewFieldSetName =
      this.existingConfig.Preview_Screen_Field_Set_API_Name__c;
    this.requiredPermissionName = this.existingConfig.Required_Permission__c;
    this.isActionInAsync =
      this.existingConfig.Is_Action_Flow_Execution_in_Async_Mode__c;
    this.customMessage = this.existingConfig.Custom_Success_Message__c;
  }

  handleNext() {
    this.validateInputs();
  }

  handlePrev() {
    this.selectedStep = CONSTANTS.STEPS.STEP + --this.selectedIndex;
    this.showPrev = this.selectedIndex !== 1;
    this.isFinalStep = this.selectedIndex === 6;
  }

  handleRequiredPermissionToggleChange() {
    this.isRestrictedAction = !this.isRestrictedAction;
  }

  handleEvalFlowToggleChange() {
    this.isEvalFlowRequired = !this.isEvalFlowRequired;
  }

  handleInputFlowToggleChange() {
    this.isInputFlowRequired = !this.isInputFlowRequired;
  }

  handleAsyncActionToggleChange() {
    this.isActionInAsync = !this.isActionInAsync;
  }

  setBulkActionName(event) {
    this.bulkActionName = event.target.value;
  }

  setBulkActionObject(event) {
    this.bulkActionObject = event.target.value;
  }

  setRequiredPermission(event) {
    this.requiredPermissionName = event.target.value;
  }

  setFieldSet(event) {
    this.previewFieldSetName = event.target.value;
  }

  setPreviewButtonName(event) {
    this.previewButtonName = event.target.value;
  }

  setEvalFlow(event) {
    this.evalFlowAPIName = this.formatToApiName(event.target.value);
  }

  setEvalFlowMessage(event) {
    this.evalFlowMessage = event.target.value;
  }

  setInputFlowAPIName(event) {
    this.inputFlowAPIName = this.formatToApiName(event.target.value);
  }

  setActionFlow(event) {
    this.actionFlowAPIName = this.formatToApiName(event.target.value);
  }

  setCustomMessage(event) {
    this.customMessage = event.target.value;
  }

  validateInputs() {
    let err = "";
    switch (this.selectedIndex) {
      case 1:
        err = this.validateInputsForStep1();
        break;
      case 2:
        err = this.validateInputsForStep2();
        break;
      case 3:
        err = this.validateInputsForStep3();
        break;
      case 4:
        err = this.validateInputsForStep4();
        break;
      case 5:
        err = this.validateInputsForStep5();
        break;
      default:
        return;
    }
    if (err !== "") {
      this.showMessage(err);
      return;
    }
    this.selectedStep = "Step" + ++this.selectedIndex;
    this.isFinalStep = this.selectedIndex === 6;
    this.showPrev = this.selectedIndex !== 1;
    this.selectedIndex = parseInt(
      this.selectedStep.split(CONSTANTS.STEPS.STEP).pop(),
      10
    );
  }

  validateInputsForStep1() {
    let err = "";
    err +=
      this.bulkActionName === undefined || this.bulkActionName === ""
        ? CONSTANTS.ERROR_MESSAGE.NO_BULK_ACTION_NAME
        : "";
    err +=
      this.bulkActionObject === undefined || this.bulkActionObject === ""
        ? CONSTANTS.ERROR_MESSAGE.NO_BULK_ACTION_OBJECT
        : "";
    err +=
      this.isRestrictedAction &&
      (this.requiredPermissionName === undefined ||
        this.requiredPermissionName === "")
        ? CONSTANTS.ERROR_MESSAGE.NO_PERM_SET_NAME
        : "";
    return err;
  }

  validateInputsForStep2() {
    let err = "";
    err +=
      this.previewFieldSetName === undefined || this.bulkActionName === ""
        ? CONSTANTS.ERROR_MESSAGE.NO_FIELD_SET
        : "";
    return err;
  }

  validateInputsForStep3() {
    let err = "";
    err +=
      this.isEvalFlowRequired &&
      (this.evalFlowAPIName === undefined || this.evalFlowAPIName === "")
        ? CONSTANTS.ERROR_MESSAGE.NO_EVAL_FLOW
        : "";
    return err;
  }

  validateInputsForStep4() {
    let err = "";
    err +=
      this.isInputFlowRequired &&
      (this.inputFlowAPIName === undefined || this.inputFlowAPIName === "")
        ? CONSTANTS.ERROR_MESSAGE.NO_INPUT_FLOW
        : "";
    return err;
  }

  validateInputsForStep5() {
    let err = "";
    err +=
      this.actionFlowAPIName === undefined || this.actionFlowAPIName === ""
        ? CONSTANTS.ERROR_MESSAGE.NO_ACTION_FLOW
        : "";
    return err;
  }

  insertConfiguration() {
    insertConfig({ config: this.config }).then((result) => {
      if (result && result.errorMessage && result.errorMessage.length > 0) {
        this.showMessage(result.errorMessage);
      } else if (result.jobId) {
        this.jobId = result.jobId;
        this.isDeploymentLinkVisible = true;
      }
    });
  }

  navigateToHome() {
    window.location = "/lightning/n/Bulk_Actions";
  }

  showMessage(err) {
    if (err !== undefined) {
      this.showToastMessage(err, CONSTANTS.ERROR_THEME, "Validation Error");
    }
  }

  showToastMessage(alertMessage, theme, title) {
    LightningAlert.open({
      message: alertMessage,
      theme: theme,
      label: title
    }).then(() => {});
  }

  formatToApiName(val) {
    return val
      .replace("[0-9]*", "")
      .replaceAll(REGEX_IGNORE_NUMBER_ALPHABETS, " ")
      .replaceAll(" ", "_")
      .replaceAll("[_+]", "_");
  }
}
