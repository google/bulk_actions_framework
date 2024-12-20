/**
 * @group Test
 * @description Tests for BulkActionRecordDetailsFetcher
 */
@IsTest(isParallel=true)
private class BulkActionRecordDetailsFetcherTest {
  private static Case sampleCase = BulkActionsTestDataUtil.getSampleCase();

  @IsTest
  private static void getTableDetailsShouldThrowExceptionOnInvalidFS() {
    Boolean isException = false;
    BulkActionTable table;
    try {
      table = BulkActionRecordDetailsFetcher.getTableDetails(
        new List<Id>{ sampleCase.Id },
        'TestFS' + System.now()
      );
    } catch (IllegalArgumentException ex) {
      isException = true;
    }
    System.assertEquals(
      true,
      isException,
      'Exception should be thrown on invalid variables'
    );
    System.assertEquals(
      null,
      table,
      'Table should not be populated on invalid fieldset name'
    );
  }

  @IsTest
  private static void processLevelOneLookupShouldReturnDetails() {
    Schema.DescribeSObjectResult describeSObjectResultObj = BulkActionRecordDetailsFetcher.getDescribeObjectResult(
      'Case'
    );
    Map<String, Schema.SObjectField> fieldAPItoFieldMap = describeSObjectResultObj.fields.getMap();
    BulkActionTable.Column lookupCol = BulkActionRecordDetailsFetcher.processLevelOneLookup(
      'Contact.Name',
      fieldAPItoFieldMap
    );
    System.assertNotEquals(
      null,
      lookupCol,
      'Method should return valid lookup details'
    );
  }

  @IsTest
  private static void tableRowsBuilderShouldReturnRows() {
    FakeSelectorBulkActionRecordDetailsFetcher fakeSelector = new FakeSelectorBulkActionRecordDetailsFetcher(
      new List<sObject>{ sampleCase }
    );
    BulkActionRecordDetailsFetcher.selector = fakeSelector;
    Schema.DescribeSObjectResult describeSObjectResultObj = BulkActionRecordDetailsFetcher.getDescribeObjectResult(
      'Case'
    );
    Map<String, Schema.SObjectField> fieldAPItoFieldMap = describeSObjectResultObj.fields.getMap();
    List<BulkActionTable.Column> columns = new List<BulkActionTable.Column>();
    DescribeFieldResult fieldResult = fieldAPItoFieldMap.get('Id')
      ?.getDescribe();
    columns.add(
      new BulkActionRecordDetailsFetcher.TableColumnBuilder()
        .setFieldResult(fieldResult)
        .build()
    );
    List<BulkActionTable.Row> rows = new BulkActionRecordDetailsFetcher.TableRowsBuilder()
      .setRecordIds(new List<Id>{ sampleCase.Id })
      .setObjName('Case')
      .setColumns(columns)
      .build();

    System.assertNotEquals(
      null,
      rows,
      'Method should return valid table row details'
    );

    System.assertEquals(
      1,
      rows.size(),
      'Method should return single row details'
    );

    System.assertEquals(
      sampleCase.Id,
      rows[0].displayRecord.Id,
      'Method should return a data with related record details'
    );
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
