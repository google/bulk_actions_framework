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
