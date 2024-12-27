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

export default class BulkActionSetupConfigDetails extends LightningElement {
  @api config;
  @api mode;
  showEdit = false;

  get isReadOnly() {
    return this.mode === "readOnly";
  }

  get columnsCSS() {
    return this.mode === "edit"
      ? "slds-col slds-size_12-of-12"
      : "slds-col slds-size_4-of-12";
  }

  get flowDetails() {
    return {
      evalFlow: this.config.Eval_Flow_API_Name__c,
      inputFlow: this.config.Input_Flow_API_Name__c,
      actionFlow: this.config.Action_Flow_API_Name__c,
      fieldSet: this.config.Preview_Screen_Field_Set_API_Name__c,
      bulkActionName: this.config.MasterLabel,
      bulkActionObject: this.config.Object_API_Name__c
    };
  }

  handleBack() {
    window.location = "/lightning/n/Bulk_Actions";
  }

  editConfiguration() {
    this.showEdit = true;
  }
}
