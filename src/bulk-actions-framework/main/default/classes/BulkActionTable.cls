/**
 * @group: Struct
 * @description: Wrapper class for bulk actions output
 */
public inherited sharing class BulkActionTable {
  @AuraEnabled
  public String objectName { get; set; }

  @AuraEnabled
  public List<Id> selectedRecordIds { get; set; }

  @AuraEnabled
  public String returnURL { get; set; }

  @AuraEnabled
  public List<BulkActionTable.Column> columns { get; set; }

  @AuraEnabled
  public List<BulkActionTable.Row> rows { get; set; }

  public BulkActionTable() {
  }

  public BulkActionTable(
    String objectName,
    List<Id> selectedRecordIds,
    List<BulkActionTable.Column> columns,
    List<BulkActionTable.Row> rows
  ) {
    this.objectName = objectName;
    this.selectedRecordIds = selectedRecordIds;
    this.columns = columns;
    this.rows = rows;
    this.returnURL = String.format(
      BulkActionConstants.RET_URL,
      new List<String>{ this.objectName }
    );
  }

  public class Column {
    //field label
    @AuraEnabled
    public String label { get; set; }
    //field api name
    @AuraEnabled
    public String apiName { get; set; }
    //data type of the field
    @AuraEnabled
    public String fieldDataType { get; set; }
    //help text for the field
    @AuraEnabled
    public String helpText { get; set; }
  }

  public class Row {
    //sObject record used for displaying data on preview screen
    @AuraEnabled
    public sObject displayRecord { get; set; }
    //boolean variable used to check eligibility condition for row, this is returned by evaluation flow
    @AuraEnabled
    public Boolean isValid { get; set; }
    //additional variables that can be used to pass diffrent details from flows to lwc
    @AuraEnabled
    public String outputMessage { get; set; }
    //used to represet status of the action for each row, this is returned by action flow
    @AuraEnabled
    public String actionStatus { get; set; }
    //used to represet status of the action for each row, this is returned by action flow
    @AuraEnabled
    public String actionErrorMessage { get; set; }

    public Row() {
      //default isVaild to true so that if no evaluation flow  preset,
      //all the selected records will be shown in preview table
      this.isValid = true;
    }
  }
}
