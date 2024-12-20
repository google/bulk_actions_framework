/**
 * @group: Test
 * @description Test class for BulkActionSetupController
 */
@IsTest(isParallel=true)
private with sharing class BulkActionSetupControllerTest {
  @IsTest
  private static void insertConfigShouldThrowException() {
    Bulk_Action_Configuration__mdt conf = new Bulk_Action_Configuration__mdt();
    conf.MasterLabel = 'Test';

    BulkActionSetupController.CustomMetadataCreateResult result = BulkActionSetupController.insertConfig(
      conf
    );

    System.assertEquals(
      true,
      result.errorMessage.size() > 0,
      'Exception should be thrown if tried to deployed from test class'
    );
    System.assertEquals(
      'Metadata cannot be deployed from within a test',
      result.errorMessage[0],
      'Exception should be thrown if tried to deployed from test class'
    );
  }
}
