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
import { getConstants } from "c/bulkActionSetupUtil";

//constants
const CONSTANTS = getConstants();

const columns = [
  {
    label: "Variable Name",
    fieldName: "Name",
    fixedWidth: 200,
    wrapText: true
  },
  { label: "Type", fieldName: "Type", fixedWidth: 100 },
  {
    label: "I/O?",
    fixedWidth: 100,
    cellAttributes: {
      iconName: { fieldName: "inputIcon" },
      iconPosition: "right"
    }
  },
  {
    label: "Required",
    fixedWidth: 100,
    cellAttributes: {
      iconName: { fieldName: "requiredIcon" },
      iconPosition: "right"
    }
  },
  { label: "Description", fieldName: "Description", wrapText: true }
];

export default class BulkActionSetupFlowBuilderGuide extends LightningElement {
  @api flowDetails;
  columns = columns;
  evalFlowDetails = CONSTANTS.FLOWS.EVAL_FLOW;
  actionFlowDetails = CONSTANTS.FLOWS.ACTION_FLOW;
  selectedItem = "Evaluation_Flow";

  _isEvalVisible = true;
  _isInputVisible = false;
  _isActionVisible = false;
  _isOtherSetupVisible = false;

  get isEvalVisible() {
    return this._isEvalVisible;
  }

  set isEvalVisible(value) {
    this._isEvalVisible = value;
  }

  get isInputVisible() {
    return this._isInputVisible;
  }

  set isInputVisible(value) {
    this._isInputVisible = value;
  }

  get isActionVisible() {
    return this._isActionVisible;
  }

  set isActionVisible(value) {
    this._isActionVisible = value;
  }

  get isOtherSetupVisible() {
    return this._isOtherSetupVisible;
  }

  set isOtherSetupVisible(value) {
    this._isOtherSetupVisible = value;
  }

  get buttonUrl() {
    return (
      '{!URLFOR("/flow/Bulk_Action_Initializer?bulkActionTemplateName=' +
      this.flowDetails.bulkActionName +
      '")}'
    );
  }

  handleSelect(event) {
    this.selectedItem = event.detail.name;
    if (this.selectedItem === "Evaluation_Flow") {
      this.isActionVisible = false;
      this.isInputVisible = false;
      this.isEvalVisible = true;
      this.isOtherSetupVisible = false;
    } else if (this.selectedItem === "Input_Flow") {
      this.isActionVisible = false;
      this.isInputVisible = true;
      this.isEvalVisible = false;
      this.isOtherSetupVisible = false;
    } else if (this.selectedItem === "Action_Flow") {
      this.isActionVisible = true;
      this.isInputVisible = false;
      this.isEvalVisible = false;
      this.isOtherSetupVisible = false;
    } else if (this.selectedItem === "Other_Setup") {
      this.isActionVisible = false;
      this.isInputVisible = false;
      this.isEvalVisible = false;
      this.isOtherSetupVisible = true;
    }
  }
}
