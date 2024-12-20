/**
 * @group Test
 * @description Tests for BulkActionSetupListController
 */
@IsTest(isParallel=true)
private with sharing class BulkActionSetupListControllerTest {
  @IsTest
  private static void getConfigShouldReturnRecords() {
    FakeBulkActionSetupListController fakeSelector = new FakeBulkActionSetupListController(
      new List<Bulk_Action_Configuration__mdt>{
        BulkActionsTestDataUtil.getConfig()
      }
    );

    // To cover default selector
    BulkActionSetupListController.getConfig();

    BulkActionSetupListController.selector = fakeSelector;

    System.assertEquals(
      true,
      BulkActionSetupListController.getConfig().size() > 0,
      'Get config method should return configuration records'
    );
  }

  private inherited sharing class FakeBulkActionSetupListController extends BulkActionSetupListController.Selector {
    public List<Bulk_Action_Configuration__mdt> recordsList;
    /**
     * @description fake selector constructor
     * @param recordsList - List of Bulk_Action_Configuration__mdt records
     */
    public FakeBulkActionSetupListController(
      List<Bulk_Action_Configuration__mdt> recordsList
    ) {
      this.recordsList = recordsList;
    }
    public override List<Bulk_Action_Configuration__mdt> getAllConfigs() {
      return this.recordsList;
    }
  }
}
