/**
 * @group: Controller
 * @description: Controller class for Bulk Action Executor LWC
 */
public with sharing class BulkActionExecutorController {
  @TestVisible
  private static String exceptionMessage = '';

  /**
   * @description method to get configuration defined for selected bulk action,
   * configuration name is provided and config meta is returned
   * @param String, Bulk_Action_Config__mdt - developerName
   * @return Record, Bulk_Action_Config__mdt record matching developerName
   */
  @AuraEnabled(cacheable=true)
  public static Bulk_Action_Configuration__mdt getConfig(String configName) {
    Bulk_Action_Configuration__mdt config = BulkActionUtil.getConfig(
      configName
    );
    exceptionMessage = BulkActionIOValidator.validateConfiguration(config);
    if (exceptionMessage != '') {
      throw new BulkActionsException(exceptionMessage);
    }
    return config;
  }

  /**
   * @description method to get BulkActionTable wrapper with required fields and data for selected records
   * @param List<Id>, selected record id`s on which action to be performed
   * @param String, field set api name
   * @return BulkActionTable, BulkActionTable wrapper with columns and rows populated
   */
  @AuraEnabled(cacheable=true)
  public static BulkActionTable getTableDetails(
    List<Id> recordIds,
    String fieldSetName
  ) {
    return BulkActionRecordDetailsFetcher.getTableDetails(
      recordIds,
      fieldSetName
    );
  }

  /**
   * @description method to validate selected records meeting the evaluation flow criteria
   * @param BulkActionTable, wrapper consists of details for selected records
   * @param String, evaluation flow name
   * @return List<BulkActionTable.Row>, returns the updated list with BulkActionTable.Row.isValid flag updated
   * as per evaluation flow output
   */
  @AuraEnabled
  public static List<BulkActionTable.Row> executeEvaluationFlow(
    BulkActionTable table,
    String evalFlowApiName
  ) {
    List<Invocable.Action.Result> results = BulkActionUtil.invokeBulkActionFlows(
      table,
      evalFlowApiName,
      BulkActionConstants.FLOW_TYPE_EVAL
    );
    for (Integer i = 0; i < table.rows.size(); i++) {
      Invocable.Action.Result result = results[i];
      BulkActionTable.Row row = table.rows[i];
      if (result.isSuccess()) {
        BulkActionIOValidator.validateEvalFlowParamenters(
          result,
          evalFlowApiName
        );
        //Assigning values to wrapper variables
        row.isValid = (Boolean) result.getOutputParameters()
          .get(BulkActionConstants.EVAL_FLOW_OP_IS_VALID);
        row.outputMessage = (String) result.getOutputParameters()
          .get(BulkActionConstants.EVAL_FLOW_OP_MSG);
      } else {
        throw new AuraHandledException(
          getFormattedErrorMessage(result.getErrors())
        );
      }
    }
    return table.rows;
  }

  /**
   * @description method to execute action flow
   * @param BulkActionTable, wrapper which constists of details for all the selected records
   * @param Bulk_Action_Config__mdt, related config for required bulk action
   * @param Map<String, Object>, additional inputs captured via input flow
   * @return List<BulkActionTable.Row>, returns BulkActionTable.Row
   */
  @AuraEnabled
  public static List<BulkActionTable.Row> executeActionFlow(
    BulkActionTable table,
    Bulk_Action_Configuration__mdt config,
    Map<String, Object> screenFlowInputs
  ) {
    String evalFlowApiName = config.Eval_Flow_API_Name__c;
    String actionFlowApiName = config.Action_Flow_API_Name__c;
    List<BulkActionTable.Row> actionRows = new List<BulkActionTable.Row>();
    if (evalFlowApiName != null) {
      actionRows = reEvalEvalFlowForActionFlow(table, evalFlowApiName);
    } else {
      actionRows = table.rows;
    }
    table.rows = actionRows;
    List<Invocable.Action.Result> results = BulkActionUtil.invokeBulkActionFlows(
      table,
      actionFlowApiName,
      BulkActionConstants.FLOW_TYPE_ACTION,
      screenFlowInputs
    );
    return amendActionResult(config, actionRows, results);
  }

  /**
   * @description method to execute action flow just before calling action flow
   * @param BulkActionTable, wrapper which constists of details for all the selected records
   * @param String, evaluation flow name
   * @return List<BulkActionTable.Row>, returns BulkActionTable.Row
   */
  private static List<BulkActionTable.Row> reEvalEvalFlowForActionFlow(
    BulkActionTable table,
    String evalFlowApiName
  ) {
    List<BulkActionTable.Row> actionRows = new List<BulkActionTable.Row>();
    for (
      BulkActionTable.Row evalResults : executeEvaluationFlow(
        table,
        evalFlowApiName
      )
    ) {
      if (evalResults.isValid) {
        actionRows.add(evalResults);
      }
    }
    return actionRows;
  }

  /**
   * @description method to execute action flow just before calling action flow
   * @param Bulk_Action_Config__mdt, related config for required bulk action
   * @param List<BulkActionTable.Row>, details for rows on which action is performed
   * @param List<Invocable.Action.Result>, action result
   * @return List<BulkActionTable.Row>, returns updated list of BulkActionTable.Row
   */
  private static List<BulkActionTable.Row> amendActionResult(
    Bulk_Action_Configuration__mdt config,
    List<BulkActionTable.Row> actionRows,
    List<Invocable.Action.Result> results
  ) {
    for (Integer i = 0; i < actionRows.size(); i++) {
      Invocable.Action.Result result = results[i];
      BulkActionTable.Row row = actionRows[i];

      //Check for handled exception
      String err = String.valueOf(
        result?.getOutputParameters()?.get('errorMessage')
      );
      if (err != null) {
        row.actionStatus = BulkActionConstants.ERROR;
        row.actionErrorMessage = err;
      } else {
        if (result.isSuccess()) {
          row.actionStatus = config.is_Action_Flow_Execution_in_Async_Mode__c
            ? BulkActionConstants.INPROGRESS
            : BulkActionConstants.SUCCESS;
        } else {
          //Unhandled exception check
          row.actionStatus = BulkActionConstants.ERROR;
          row.actionErrorMessage = getFormattedErrorMessage(result.getErrors());
        }
      }
    }
    return actionRows;
  }

  private static String getFormattedErrorMessage(
    List<Invocable.Action.Error> errors
  ) {
    List<String> messagesAndCodes = new List<String>();
    for (Invocable.Action.Error error : errors) {
      messagesAndCodes.add(error.getCode() + ' - ' + error.getMessage());
    }
    return String.join(messagesAndCodes, ', ');
  }
}
