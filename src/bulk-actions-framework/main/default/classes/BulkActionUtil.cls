/*
 * Copyright 2024 Google LLC
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *     http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

/**
 * @group: Util
 * @description: utility methods for Bulk Action Framework
 */
public with sharing class BulkActionUtil {
  @TestVisible
  private static final String INVALID_INPUT = 'Both `record` and `flowApiName` are required to call `Bulk Action Flows`';

  @TestVisible
  private static BulkActionUtil.Selector selector = new BulkActionUtil.Selector();
  @TestVisible
  private static InvocableAction invocableAction = new InvocableAction();

  /**
   * @description method to get configuration defined for selected bulk action,
   * configuration name is provided and config meta is returned
   * @param String, Bulk_Action_Configuration__mdt - developerName
   * @return Record, Bulk_Action_Configuration__mdt record matching developerName
   */
  public static Bulk_Action_Configuration__mdt getConfig(String configName) {
    List<Bulk_Action_Configuration__mdt> config = selector.getBulkActionTemplate(
      configName
    );
    return config.size() != 0 ? config[0] : null;
  }

  /**
   * @description method to get object prefixes for selected records
   * @param List<Id>, selected record id`s on which action to be performed
   * @return Set<String>, set of objects prefixes corrosponding to input records,
   * ideally this should be set with only single element
   */
  public static Set<String> getObjectsFromRecordIds(List<Id> recordIds) {
    Set<String> objectPrefixes = new Set<String>();
    for (Id recId : recordIds) {
      objectPrefixes.add(String.valueOf(recId).subString(0, 3));
    }
    return objectPrefixes;
  }

  public static List<Invocable.Action.Result> invokeBulkActionFlows(
    BulkActionTable table,
    String flowApiName,
    String flowType
  ) {
    return invokeBulkActionFlows(table, flowApiName, flowType, null);
  }

  public static List<Invocable.Action.Result> invokeBulkActionFlows(
    BulkActionTable table,
    String flowApiName,
    String flowType,
    Map<String, Object> screenFlowInputs
  ) {
    if (
      table?.rows == null ||
      (flowType == BulkActionConstants.FLOW_TYPE_ACTION &&
      flowApiName == null)
    ) {
      throw new IllegalArgumentException(INVALID_INPUT);
    }
    Map<Id, SObject> recordIdToRecordMap = BulkActionRecordDetailsFetcher.getFullyPopulatedRecord(
      table.objectName,
      table.selectedRecordIds
    );
    List<Map<String, Object>> interviewInputs = new List<Map<String, Object>>();
    for (BulkActionTable.Row row : table.rows) {
      Map<String, Object> inputs = new Map<String, Object>();
      inputs.put(
        BulkActionConstants.RECORD_VARIABLE,
        recordIdToRecordMap.get(row.displayRecord.Id)
      );
      if (screenFlowInputs != null && screenFlowInputs.keySet().size() > 0) {
        inputs.putAll(screenFlowInputs);
      }
      interviewInputs.add(inputs);
    }
    return invocableAction.invokeAction(flowApiName, interviewInputs);
  }

  @TestVisible
  public virtual class InvocableAction {
    public virtual List<Invocable.Action.Result> invokeAction(
      String flowApiName,
      List<Map<String, Object>> inputs
    ) {
      Invocable.Action action = Invocable.Action.createCustomAction(
        'Flow',
        flowApiName
      );
      action.setInvocations(inputs);
      return action.invoke();
    }
  }

  public static String getDataType(Object obj) {
    String varDataType = 'undefined';
    if (obj instanceof Integer) {
      varDataType = 'Integer';
    } else if (obj instanceof Double) {
      varDataType = 'Double';
    } else if (obj instanceof String) {
      varDataType = 'String';
    } else if (obj instanceof Blob) {
      varDataType = 'Blob';
    } else if (obj instanceof Boolean) {
      varDataType = 'Boolean';
    } else if (obj instanceof Date) {
      varDataType = 'Date';
    } else if (obj instanceof Datetime) {
      varDataType = 'DateTime';
    } else if (obj instanceof Decimal) {
      varDataType = 'Decimal';
    } else if (obj instanceof ID) {
      varDataType = 'Id';
    } else if (obj instanceof Long) {
      varDataType = 'Long';
    } else if (obj instanceof Time) {
      varDataType = 'Time';
    }
    return (varDataType);
  }

  @TestVisible
  private virtual inherited sharing class Selector {
    public virtual List<Bulk_Action_Configuration__mdt> getBulkActionTemplate(
      String configName
    ) {
      return [
        SELECT
          Custom_Success_Message__c,
          DeveloperName,
          MasterLabel,
          Action_Flow_API_Name__c,
          Eval_Flow_API_Name__c,
          Eval_Flow_Error_Message__c,
          Input_Flow_API_Name__c,
          Is_Action_Flow_Execution_in_Async_Mode__c,
          Preview_Screen_Button_Name__c,
          Preview_Screen_Field_Set_API_Name__c,
          Required_Permission__c
        FROM Bulk_Action_Configuration__mdt
        WHERE DeveloperName = :configName
        LIMIT 1
      ];
    }
  }
}
