/**
 * @group Test
 * @description Tests for BulkActionExecutorController
 */
@IsTest(isParallel=true)
private with sharing class BulkActionExecutorControllerTest {
  private static final String FLOW_API_NAME = 'Test Flow';
  private static final String OBJ_NAME = 'Case';

  //Data Setup
  private static Bulk_Action_Configuration__mdt config = BulkActionsTestDataUtil.getConfig();
  private static Case sampleCase = BulkActionsTestDataUtil.getSampleCase();
  private static Invocable.Action.Result evalFlowSuccessResult = BulkActionsTestDataUtil.getValidInvocableResult();
  private static Invocable.Action.Result evalFlowErrorResultInvalidOutputIsValid = BulkActionsTestDataUtil.getInvalidInvocableResultForIsValidFlag();
  private static Invocable.Action.Result evalFlowErrorResultInvalidOutputMessage = BulkActionsTestDataUtil.getInvalidInvocableResultForOutputMessageVar();
  private static BulkActionTable sampleTable = BulkActionsTestDataUtil.getSampleTable();

  @IsTest
  private static void getConfigShouldReturnValidConfig() {
    FakeSelector fakeSelector = new FakeSelector(
      new List<Bulk_Action_Configuration__mdt>{ config }
    );
    BulkActionUtil.selector = fakeSelector;
    System.assertNotEquals(
      null,
      BulkActionExecutorController.getConfig(config.DeveloperName),
      'Bulk action configuration should not be null'
    );
  }

  @IsTest
  private static void getConfigShouldThrowExceptionOnInvalidConfigOnNullFS() {
    Boolean isException = false;
    config.Preview_Screen_Field_Set_API_Name__c = null;
    FakeSelector fakeSelector = new FakeSelector(
      new List<Bulk_Action_Configuration__mdt>{ config }
    );
    BulkActionUtil.selector = fakeSelector;
    try {
      BulkActionExecutorController.getConfig(config.DeveloperName);
    } catch (BulkActionsException ex) {
      isException = true;
    }
    System.assertEquals(
      true,
      isException,
      'Exception should be thrown on invalid variables'
    );
    System.assertEquals(
      String.format(
        BulkActionErrorsAndMessages.ERR_NO_FIELD_SET,
        new List<String>{ config.MasterLabel }
      ),
      BulkActionExecutorController.exceptionMessage,
      'Bulk action configuration should have field set name defined'
    );
  }

  @IsTest
  private static void getConfigShouldThrowExceptionOnInvalidConfigOnNullAF() {
    config.Action_Flow_API_Name__c = null;
    Boolean isException = false;
    FakeSelector fakeSelector = new FakeSelector(
      new List<Bulk_Action_Configuration__mdt>{ config }
    );
    BulkActionUtil.selector = fakeSelector;
    try {
      BulkActionExecutorController.getConfig(config.DeveloperName);
    } catch (BulkActionsException ex) {
      isException = true;
    }
    System.assertEquals(
      true,
      isException,
      'Exception should be thrown on invalid variables'
    );
    System.assertEquals(
      String.format(
        BulkActionErrorsAndMessages.ERR_NO_ACTION_FLOW,
        new List<String>{ config.MasterLabel }
      ),
      BulkActionExecutorController.exceptionMessage,
      'Bulk action configuration should have action flow name defined'
    );
  }

  @IsTest
  private static void getTableDetailsShouldReturnTableDetails() {
    Map<String, Schema.FieldSet> fieldSetObj = Case.sObjectType.getDescribe(
        SObjectDescribeOptions.DEFERRED
      )
      .FieldSets.getMap();
    if (fieldSetObj.keySet()?.size() == 0) {
      return;
    }
    String fieldSetName = (new List<string>(fieldSetObj.keySet()))[0];
    FakeSelectorBulkActionRecordDetailsFetcher fakeSelector = new FakeSelectorBulkActionRecordDetailsFetcher(
      new List<sObject>{ sampleCase }
    );
    BulkActionRecordDetailsFetcher.selector = fakeSelector;
    BulkActionTable table = BulkActionExecutorController.getTableDetails(
      new List<Id>{ sampleCase.Id },
      fieldSetName
    );
    System.assertNotEquals(null, table, 'Table details should not be null');
    System.assertEquals(
      1,
      table.rows.size(),
      'Table details should be populated'
    );
    System.assertEquals(
      sampleCase.Id,
      table.rows[0].displayRecord.Id,
      'Table details should be populated'
    );
  }

  @IsTest
  private static void executeEvalFlowShouldExecuteFlow() {
    BulkActionUtil.InvocableAction act = new FakeInvocableAction(
      new List<Invocable.Action.Result>{ evalFlowSuccessResult }
    );
    BulkActionUtil.invocableAction = act;
    List<BulkActionTable.Row> result = BulkActionExecutorController.executeEvaluationFlow(
      sampleTable,
      FLOW_API_NAME
    );
    for (BulkActionTable.Row row : result) {
      System.assertEquals(
        true,
        row.isValid,
        'Is Valid flag should be set to true'
      );
    }
  }

  @IsTest
  private static void executeEvalFlowShouldThrowExInvalidInput() {
    Boolean isException = false;
    String exMessage;
    try {
      BulkActionExecutorController.executeEvaluationFlow(null, null);
    } catch (IllegalArgumentException ex) {
      isException = true;
      exMessage = ex.getMessage();
    }
    System.assertEquals(
      true,
      isException,
      'Exception should be thrown on invalid variables'
    );
    System.assertEquals(
      BulkActionUtil.INVALID_INPUT,
      exMessage,
      'System should throw exception on invalid inputs'
    );
  }

  @IsTest
  private static void executeEvalFlowShouldThrowExInvalidOutputIsValid() {
    Boolean isException = false;
    String exMessage;
    BulkActionUtil.InvocableAction act = new FakeInvocableAction(
      new List<Invocable.Action.Result>{
        evalFlowErrorResultInvalidOutputIsValid
      }
    );
    BulkActionUtil.invocableAction = act;
    try {
      BulkActionExecutorController.executeEvaluationFlow(
        sampleTable,
        FLOW_API_NAME
      );
    } catch (IllegalArgumentException ex) {
      isException = true;
      exMessage = ex.getMessage();
    }
    System.assertEquals(
      true,
      isException,
      'Exception should be thrown on invalid variables'
    );
    System.assertEquals(
      String.format(
        BulkActionErrorsAndMessages.INVALID_FLOW_VARIABLE,
        new List<String>{
          FLOW_API_NAME,
          BulkActionIOValidator.EVAL_FLOW_PARA_MAP.get(
              BulkActionConstants.FLOW_VAR_REQUIRED
            )
            .get(BulkActionConstants.EVAL_FLOW_OP_IS_VALID),
          BulkActionConstants.EVAL_FLOW_OP_IS_VALID
        }
      ),
      exMessage,
      'System should throw exception on invalid output variables'
    );
  }

  @IsTest
  private static void executeEvalFlowShouldThrowExInvalidOutputMessage() {
    Boolean isException = false;
    String exMessage;
    BulkActionUtil.InvocableAction act = new FakeInvocableAction(
      new List<Invocable.Action.Result>{
        evalFlowErrorResultInvalidOutputMessage
      }
    );
    BulkActionUtil.invocableAction = act;
    try {
      BulkActionExecutorController.executeEvaluationFlow(
        sampleTable,
        FLOW_API_NAME
      );
    } catch (IllegalArgumentException ex) {
      isException = true;
      exMessage = ex.getMessage();
    }
    System.assertEquals(
      true,
      isException,
      'Exception should be thrown on invalid variables'
    );
    System.assertEquals(
      String.format(
        BulkActionErrorsAndMessages.INVALID_FLOW_VARIABLE,
        new List<String>{
          FLOW_API_NAME,
          BulkActionIOValidator.EVAL_FLOW_PARA_MAP.get(
              BulkActionConstants.FLOW_VAR_OPTIONAL
            )
            .get(BulkActionConstants.EVAL_FLOW_OP_MSG),
          BulkActionConstants.EVAL_FLOW_OP_MSG
        }
      ),
      exMessage,
      'System should throw exception on invalid output variables'
    );
  }

  @IsTest
  private static void executeActionFlowShouldExecuteFlow() {
    BulkActionUtil.InvocableAction act = new FakeInvocableAction(
      new List<Invocable.Action.Result>{ evalFlowSuccessResult }
    );
    BulkActionUtil.invocableAction = act;
    List<BulkActionTable.Row> result = BulkActionExecutorController.executeActionFlow(
      sampleTable,
      config,
      null
    );
    for (BulkActionTable.Row row : result) {
      System.assertEquals(
        BulkActionConstants.SUCCESS,
        row.actionStatus,
        'Is Valid flag should be set to true'
      );
    }
  }

  @IsTest
  private static void shouldCoverSelectors() {
    QueryException testException;
    try {
      BulkActionUtil.Selector.getBulkActionTemplate(config.MasterLabel);
      BulkActionRecordDetailsFetcher.Selector.getDisplayRecords(
        new List<Id>{ sampleCase.Id },
        new List<String>{ 'Id' },
        OBJ_NAME
      );
    } catch (QueryException executionException) {
      testException = executionException;
    }
    System.assertEquals(
      null,
      testException,
      'getBulkActionTemplate method should not throw any error'
    );
  }

  private virtual class FakeInvocableAction extends BulkActionUtil.InvocableAction {
    private List<Invocable.Action.Result> result;
    public FakeInvocableAction(List<Invocable.Action.Result> result) {
      this.result = result;
    }
    public override List<Invocable.Action.Result> invokeAction(
      String flowApiName,
      List<Map<String, Object>> inputs
    ) {
      return this.result;
    }
  }

  private inherited sharing class FakeSelector extends BulkActionUtil.Selector {
    public List<Bulk_Action_Configuration__mdt> configList;
    public FakeSelector(List<Bulk_Action_Configuration__mdt> configList) {
      this.configList = configList;
    }
    public override List<Bulk_Action_Configuration__mdt> getBulkActionTemplate(
      String configName
    ) {
      return this.configList;
    }
  }

  private inherited sharing class FakeSelectorBulkActionRecordDetailsFetcher extends BulkActionRecordDetailsFetcher.Selector {
    public List<sObject> recordsList;
    public FakeSelectorBulkActionRecordDetailsFetcher(
      List<sObject> recordsList
    ) {
      this.recordsList = recordsList;
    }
    public override List<sObject> getDisplayRecords(
      List<Id> recordIds,
      List<String> fields,
      String objectName
    ) {
      return this.recordsList;
    }
  }
}
