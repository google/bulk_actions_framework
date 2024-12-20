/**
 * @group: Controller
 * @description Contoller class for bulkActionSetupList LWC
 */
public with sharing class BulkActionSetupListController {
  @TestVisible
  private static BulkActionSetupListController.Selector selector = new BulkActionSetupListController.Selector();

  /**
   * @description gets all configuration to display on UI
   * @return - List<Bulk_Action_Configuration__mdt>
   */
  @AuraEnabled(cacheable=true)
  public static List<Bulk_Action_Configuration__mdt> getConfig() {
    return selector.getAllConfigs();
  }
  @TestVisible
  private virtual inherited sharing class Selector {
    /**
     * @description selector method to query all configuration records
     * @return - List<Bulk_Action_Configuration__mdt>
     */
    @TestVisible
    public virtual List<Bulk_Action_Configuration__mdt> getAllConfigs() {
      return Bulk_Action_Configuration__mdt.getAll().values();
    }
  }
}
