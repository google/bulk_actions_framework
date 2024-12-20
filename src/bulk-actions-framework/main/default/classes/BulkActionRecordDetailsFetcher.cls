/**
 * @group: Service
 * @description: service class having methods to get the records
 * and fields based on selected id`s and metadata configuration
 */
public with sharing class BulkActionRecordDetailsFetcher {
  @TestVisible
  private static BulkActionRecordDetailsFetcher.Selector selector = new BulkActionRecordDetailsFetcher.Selector();

  /**
   * @description returns fully populated object records
   * @param String, name of the object
   * @param String, selected record ids for which all fields needs to be queried
   * @return static Map<Id, SObject>, Map of record id to SObject
   */
  public static Map<Id, SObject> getFullyPopulatedRecord(
    String objName,
    List<String> recordIds
  ) {
    return selector.prepareSelectAllQuery(recordIds, objName);
  }

  /**
   * @description method to get BulkActionTable wrapper from provided field set
   * and record details for selected record ids
   * @param List<Id>, selected record id`s on which action to be performed
   * @param String, field set name for the preview screen details
   * @param String, additional field api names used in evaluation or action flows
   * @return BulkActionTable, BulkActionTable wrapper
   */
  public static BulkActionTable getTableDetails(
    List<Id> recordIds,
    String fieldSetName
  ) {
    return new TableDetailsBuilder()
      .setRecordIds(recordIds)
      .setFieldSetName(fieldSetName)
      .build();
  }

  /**
   * @description method to get wrapper list with field details for selected records
   * @param String, api name of the object for selected records
   * @param String, field set name for the preview screen details
   * @return List<BulkActionTable.Column>, list of BulkActionTable.Column wrapper
   */
  private static List<BulkActionTable.Column> getTableColumns(
    String objectApiName,
    String fieldSetName
  ) {
    List<BulkActionTable.Column> tabColumnList = new List<BulkActionTable.Column>();
    BulkActionIOValidator.validateInputParameters(objectApiName, fieldSetName);
    Schema.DescribeSObjectResult describeSObjectResultObj = getDescribeObjectResult(
      objectApiName
    );
    Map<String, Schema.SObjectField> fieldAPItoFieldMap = describeSObjectResultObj.fields.getMap();
    for (
      Schema.FieldSetMember fsMember : getFields(
        fieldSetName,
        describeSObjectResultObj
      )
    ) {
      DescribeFieldResult fieldResult = fieldAPItoFieldMap.get(
          fsMember.getFieldPath()
        )
        ?.getDescribe();

      if (fieldResult != null) {
        if (fieldResult.isAccessible()) {
          tabColumnList.add(
            new TableColumnBuilder().setFieldResult(fieldResult).build()
          );
        }
      } else {
        if (
          fsMember.getFieldPath().countMatches(BulkActionConstants.DOT) == 1
        ) {
          BulkActionTable.Column lookupColumn = processLevelOneLookup(
            fsMember.getFieldPath(),
            fieldAPItoFieldMap
          );
          if (lookupColumn != null) {
            tabColumnList.add(lookupColumn);
          }
        }
      }
    }
    return tabColumnList;
  }

  @TestVisible
  private static BulkActionTable.Column processLevelOneLookup(
    String lookupFieldName,
    Map<String, Schema.SObjectField> fieldAPItoFieldMap
  ) {
    BulkActionTable.Column lookupColumn;
    String relationshipAPIName = lookupFieldName
      .substring(0, lookupFieldName.indexOf(BulkActionConstants.DOT));
    String lookupName = relationshipAPIName.contains(
        BulkActionConstants.UNDERSCORE_R
      )
      ? relationshipAPIName.replace(
          BulkActionConstants.UNDERSCORE_R,
          BulkActionConstants.UNDERSCORE_C
        )
      : relationshipAPIName + BulkActionConstants.ID;

    String lookupFieldLabel = fieldAPItoFieldMap.get(lookupName)
      ?.getDescribe()
      .getLabel();

    DescribeFieldResult fieldResultForLookup = getLookupDetails(
      lookupFieldName,
      fieldAPItoFieldMap
    );
    if (fieldResultForLookup != null && fieldResultForLookup.isAccessible()) {
      lookupColumn = new TableColumnBuilder()
        .setRelationshipName(relationshipAPIName)
        .setRelationshipLabel(lookupFieldLabel)
        .setFieldResult(fieldResultForLookup)
        .build();
    }
    return lookupColumn;
  }

  @TestVisible
  private static Schema.DescribeSObjectResult getDescribeObjectResult(
    String objectApiName
  ) {
    return Schema.getGlobalDescribe()
      .get(objectApiName)
      .getDescribe(SObjectDescribeOptions.Deferred);
  }

  /**
   * @description get lokup details from lookup field
   * @param String, lookup field name
   * @param Map<String, Schema.SObjectField>, base object field map
   * @return DescribeFieldResult, DescribeFieldResult for the lookup field
   */
  private static DescribeFieldResult getLookupDetails(
    String lookupField,
    Map<String, Schema.SObjectField> fieldAPItoFieldMap
  ) {
    DescribeFieldResult fieldResult;
    String relationshipName = lookupField.substring(
      0,
      lookupField.indexOf(BulkActionConstants.DOT)
    );
    String field = lookupField.substring(
      lookupField.indexOf(BulkActionConstants.DOT) + 1,
      lookupField.length()
    );
    fieldResult = relationshipName.contains(BulkActionConstants.UNDERSCORE_R)
      ? fieldAPItoFieldMap.get(
            relationshipName.replace(
              BulkActionConstants.UNDERSCORE_R,
              BulkActionConstants.UNDERSCORE_C
            )
          )
          ?.getDescribe()
      : fieldAPItoFieldMap.get(relationshipName + BulkActionConstants.ID)
          ?.getDescribe();
    Schema.DescribeSObjectResult describeSObjectResultObj = fieldResult
        ?.getReferenceTo()[0]
      .getDescribe(SObjectDescribeOptions.Deferred);
    Map<String, Schema.SObjectField> fieldAPItoFieldMapLookup = describeSObjectResultObj.fields.getMap();
    return fieldAPItoFieldMapLookup.get(field)?.getDescribe();
  }

  /**
   * @description get field details from field set name
   * @param String, String, field set name for the preview screen details
   * @param Schema.DescribeSObjectResult, describe result
   * @return List<Schema.FieldSetMember>, list of Schema.FieldSetMember
   */
  @TestVisible
  private static List<Schema.FieldSetMember> getFields(
    String fieldSetName,
    Schema.DescribeSObjectResult describeSObjectResultObj
  ) {
    Map<String, Schema.FieldSet> fieldSetObj = describeSObjectResultObj.FieldSets.getMap();
    Schema.FieldSet aFieldSet = fieldSetObj.get(fieldSetName);
    if (aFieldSet == null) {
      throw new IllegalArgumentException(
        String.format(
          BulkActionErrorsAndMessages.FIELD_SET_ERROR,
          new List<String>{ fieldSetName }
        )
      );
    }
    return aFieldSet.getFields();
  }

  private class TableDetailsBuilder {
    private List<Id> recordIds;
    private String fieldSetName;

    public TableDetailsBuilder setRecordIds(List<Id> recordIds) {
      this.recordIds = recordIds;
      return this;
    }

    public TableDetailsBuilder setFieldSetName(String fieldSetName) {
      this.fieldSetName = fieldSetName;
      return this;
    }

    public BulkActionTable build() {
      BulkActionIOValidator.checkSelectedRecordsBelongsToSameObj(
        this.recordIds
      );

      String objName = this.recordIds[0]
        .getSObjectType()
        .getDescribe()
        .getName();

      List<BulkActionTable.Column> columns = getTableColumns(
        objName,
        this.fieldSetName
      );

      List<BulkActionTable.Row> rows = new TableRowsBuilder()
        .setRecordIds(this.recordIds)
        .setObjName(objName)
        .setColumns(columns)
        .build();

      return new BulkActionTable(objName, recordIds, columns, rows);
    }
  }

  @TestVisible
  private class TableColumnBuilder {
    private Schema.DescribeFieldResult fieldResult;
    private String relationshipName;
    private String relationshipLabel;

    public TableColumnBuilder setFieldResult(
      Schema.DescribeFieldResult fieldResult
    ) {
      this.fieldResult = fieldResult;
      return this;
    }

    public TableColumnBuilder setRelationshipName(String relationshipName) {
      this.relationshipName = relationshipName;
      return this;
    }

    public TableColumnBuilder setRelationshipLabel(String relationshipLabel) {
      this.relationshipLabel = relationshipLabel;
      return this;
    }

    public BulkActionTable.Column build() {
      String colType = BulkActionConstants.DISPLAY_TYPE_TO_DATATABLE_TYPE_MAP.get(
        this.fieldResult.getType()
      );
      String helpText = this.fieldResult.getSObjectField()
        .getDescribe()
        .getInlineHelpText();
      BulkActionTable.Column tCol = new BulkActionTable.Column();
      tCol.label = this.relationshipLabel == null
        ? this.fieldResult.getLabel()
        : this.relationshipLabel +
          BulkActionConstants.DOT +
          this.fieldResult.getLabel();
      tCol.apiName = this.relationshipName == null
        ? this.fieldResult.getName()
        : this.relationshipName +
          BulkActionConstants.DOT +
          this.fieldResult.getName();
      tCol.fieldDataType = colType;
      if (String.isNotBlank(helpText)) {
        tCol.helpText = helpText;
      }
      return tCol;
    }
  }

  @TestVisible
  private class TableRowsBuilder {
    private List<Id> recordIds;
    private String objName;
    private List<BulkActionTable.Column> columns;
    public TableRowsBuilder setRecordIds(List<Id> recordIds) {
      this.recordIds = recordIds;
      return this;
    }

    public TableRowsBuilder setObjName(String objName) {
      this.objName = objName;
      return this;
    }
    public TableRowsBuilder setColumns(List<BulkActionTable.Column> columns) {
      this.columns = columns;
      return this;
    }
    public List<BulkActionTable.Row> build() {
      List<BulkActionTable.Row> rows = new List<BulkActionTable.Row>();
      List<String> fields = new List<String>();
      for (BulkActionTable.Column column : this.columns) {
        fields.add(column.apiName);
      }
      for (
        sObject rec : selector.getDisplayRecords(
          this.recordIds,
          fields,
          this.objName
        )
      ) {
        BulkActionTable.Row row = new BulkActionTable.Row();
        row.displayRecord = rec;
        rows.add(row);
      }
      return rows;
    }
  }

  @TestVisible
  private virtual inherited sharing class Selector {
    /**
     * @description method to build query string with all the fields for an object
     * and returns list of sObjects
     * @param List<Id>, selected record id`s on which action to be performed
     * @param String, object name for the records
     * @return Map<Id, SObject>, fully populated sObject records list
     */
    @TestVisible
    public virtual Map<Id, SObject> prepareSelectAllQuery(
      List<Id> recordIds,
      String objectName
    ) {
      SObjectType sObjType = ((SObject) Type.forName(objectName).newInstance())
        .getSObjectType();
      String query =
        'SELECT ' +
        String.join(
          new List<String>(
            sObjType.getDescribe(SObjectDescribeOptions.DEFERRED)
              .fields.getMap()
              .keySet()
          ),
          ', '
        ) +
        ' FROM ' +
        String.escapeSingleQuotes(objectName) +
        ' WHERE Id IN : recordIds';
      return new Map<Id, SObject>(Database.query(query));
    }

    /**
     * @description method to build query and return records with fields mentioned in field set
     * this is used for displaying details in preview screen
     * @param List<Id>, selected record id`s on which action to be performed
     * @param List<String>, fields parsed from field set
     * @param String, object name for the records
     * @return List<sObject>, map of record id to sObject records
     */
    @TestVisible
    public virtual List<sObject> getDisplayRecords(
      List<Id> recordIds,
      List<String> fields,
      String objectName
    ) {
      String query =
        'SELECT ' +
        String.join(fields, ', ') +
        ' FROM ' +
        String.escapeSingleQuotes(objectName) +
        ' WHERE Id IN : recordIds';
      return new List<sObject>(Database.query(query));
    }
  }
}
