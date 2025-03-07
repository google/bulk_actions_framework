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

import { LightningElement, wire } from "lwc";
import getConfig from "@salesforce/apex/BulkActionSetupListController.getConfig";

const actions = [
  { label: "View", name: "view" },
  { label: "Edit", name: "edit" }
];

const columns = [
  { label: "Bulk Action Name", fieldName: "MasterLabel" },
  { label: "Object API Name", fieldName: "Object_API_Name__c" },
  { label: "Required Permission", fieldName: "Required_Permission__c" },
  { label: "Evaluation Flow", fieldName: "Eval_Flow_API_Name__c" },
  { label: "Input Flow", fieldName: "Input_Flow_API_Name__c" },
  { label: "Action Flow", fieldName: "Action_Flow_API_Name__c" },
  {
    label: "Action",
    type: "action",
    initialWidth: "100px",
    typeAttributes: { rowActions: actions }
  }
];

export default class BulkActionSetupHome extends LightningElement {
  configs;
  showNoRecords = false;
  selectedConfig;
  error;
  columns = columns;
  showNewScreen = false;
  showReadOnlyScreen = false;
  showList = true;
  @wire(getConfig)
  wiredConfigs({ data, error }) {
    if (data) {
      this.configs = data;
      this.error = undefined;
      this.showNoRecords = this.configs.length === 0;
    } else {
      this.configs = undefined;
      this.error = error;
    }
  }

  handleRowAction(event) {
    let actionName = event.detail.action.name;
    this.selectedConfig = event.detail.row;
    if (actionName === "edit") {
      this.showNewConfig();
    } else if (actionName === "view") {
      this.showConfigDetails();
    }
  }

  showNewConfig() {
    this.showList = false;
    this.showNewScreen = true;
  }

  showConfigDetails() {
    this.showList = false;
    this.showReadOnlyScreen = true;
  }
}
