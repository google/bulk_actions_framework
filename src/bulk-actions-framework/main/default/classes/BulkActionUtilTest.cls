/**
 * @group Test
 * @description Tests for BulkActionUtil
 */
@IsTest(isParallel=true)
private with sharing class BulkActionUtilTest {
  private static final String FLOW_API_NAME = 'Test Flow';

  //Data Setup
  private static Bulk_Action_Configuration__mdt config = BulkActionsTestDataUtil.getConfig();
  private static Invocable.Action.Result evalFlowSuccessResult = BulkActionsTestDataUtil.getValidInvocableResult();
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
  private static void invokeBulkActionFlowsShouldInvokeFlow() {
    Boolean isException = false;
    try {
      BulkActionUtil.invokeBulkActionFlows(
        sampleTable,
        FLOW_API_NAME,
        BulkActionConstants.FLOW_TYPE_EVAL
      );
    } catch (Exception ex) {
      isException = true;
    }
    System.assertEquals(
      isException,
      false,
      'Exception should not be generated on invoking an action'
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
}
