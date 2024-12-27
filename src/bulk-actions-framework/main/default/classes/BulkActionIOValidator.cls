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

public inherited sharing class BulkActionIOValidator {
  @TestVisible
  private static String exceptionMessage = '';
  /**
   * @description Following map defines the required and optional output parameters for evaluation flow
   * if flow is set as evaluation flow in configuration record
   * and flow does not return required output variables error is displayed on UI
   * map consists of key as [Required or Optional] and value as [variable to dataType]
   */
  @TestVisible
  private static final Map<String, Map<String, String>> EVAL_FLOW_PARA_MAP = new Map<String, Map<String, String>>{
    BulkActionConstants.FLOW_VAR_REQUIRED => new Map<String, String>{
      BulkActionConstants.EVAL_FLOW_OP_IS_VALID => 'Boolean'
    },
    BulkActionConstants.FLOW_VAR_OPTIONAL => new Map<String, String>{
      BulkActionConstants.EVAL_FLOW_OP_MSG => 'String'
    }
  };

  /**
   * @description method to check if metadata config has all the required parameters populated
   * @param Bulk_Action_Configuration__mdt, configuration metadata
   * @return String, returns error messages
   */
  public static String validateConfiguration(
    Bulk_Action_Configuration__mdt config
  ) {
    if (hasConfigExists(config) != '') {
      exceptionMessage += hasConfigExists(config);
      return exceptionMessage;
    }
    exceptionMessage += hasCustomPermission(config);
    exceptionMessage += hasPreviewFieldSet(config);
    exceptionMessage += hasActionFlow(config);
    exceptionMessage += hasCustomMessage(config);
    return exceptionMessage;
  }

  @TestVisible
  private static String hasConfigExists(Bulk_Action_Configuration__mdt config) {
    String exceptionMessage = '';
    if (config == null) {
      exceptionMessage = BulkActionErrorsAndMessages.ERR_NO_CONFIG;
    }
    return exceptionMessage;
  }

  @TestVisible
  private static String hasCustomPermission(
    Bulk_Action_Configuration__mdt config
  ) {
    String exceptionMessage = '';
    if (
      config.Required_Permission__c != null &&
      !FeatureManagement.checkPermission(config.Required_Permission__c)
    ) {
      exceptionMessage = String.format(
        BulkActionErrorsAndMessages.ERR_NO_ACCESS_MESSAGE,
        new List<String>{ config.MasterLabel }
      );
    }
    return exceptionMessage;
  }

  @TestVisible
  private static String hasPreviewFieldSet(
    Bulk_Action_Configuration__mdt config
  ) {
    String exceptionMessage = '';
    if (config.Preview_Screen_Field_Set_API_Name__c == null) {
      exceptionMessage = String.format(
        BulkActionErrorsAndMessages.ERR_NO_FIELD_SET,
        new List<String>{ config.MasterLabel }
      );
    }
    return exceptionMessage;
  }

  @TestVisible
  private static String hasActionFlow(Bulk_Action_Configuration__mdt config) {
    String exceptionMessage = '';
    if (config.Action_Flow_API_Name__c == null) {
      exceptionMessage = String.format(
        BulkActionErrorsAndMessages.ERR_NO_ACTION_FLOW,
        new List<String>{ config.MasterLabel }
      );
    }
    return exceptionMessage;
  }

  @TestVisible
  private static String hasCustomMessage(
    Bulk_Action_Configuration__mdt config
  ) {
    String exceptionMessage = '';
    if (
      config.Is_Action_Flow_Execution_in_Async_Mode__c &&
      config.Custom_Success_Message__c == null
    ) {
      exceptionMessage = String.format(
        BulkActionErrorsAndMessages.ERR_NO_CONFIG_MESSAGE,
        new List<String>{ config.MasterLabel }
      );
    }
    return exceptionMessage;
  }

  /**
   * @description method to evaluate if evaluation flow returns required output variables,
   * if required variables are not found, exception is thrown and displayed on UI
   * @param Invocable.Action.Result, result
   * @return Void
   */
  public static void validateEvalFlowParamenters(
    Invocable.Action.Result result,
    String flowApiName
  ) {
    for (String varType : EVAL_FLOW_PARA_MAP.keySet()) {
      Map<String, String> variableToDataTypeMap = EVAL_FLOW_PARA_MAP.get(
        varType
      );
      for (String var : variableToDataTypeMap.keySet()) {
        Object flowOutputVar = result.getOutputParameters().get(var);
        String dataType = BulkActionUtil.getDataType(flowOutputVar);
        if (
          varType == BulkActionConstants.FLOW_VAR_REQUIRED &&
          (flowOutputVar == null ||
          dataType != EVAL_FLOW_PARA_MAP.get(varType).get(var))
        ) {
          throw new IllegalArgumentException(
            String.format(
              BulkActionErrorsAndMessages.INVALID_FLOW_VARIABLE,
              new List<String>{
                flowApiName,
                EVAL_FLOW_PARA_MAP.get(varType).get(var),
                var
              }
            )
          );
        } else if (
          varType == BulkActionConstants.FLOW_VAR_OPTIONAL &&
          (flowOutputVar != null &&
          dataType != EVAL_FLOW_PARA_MAP.get(varType).get(var))
        ) {
          throw new IllegalArgumentException(
            String.format(
              BulkActionErrorsAndMessages.INVALID_FLOW_VARIABLE,
              new List<String>{
                flowApiName,
                EVAL_FLOW_PARA_MAP.get(varType).get(var),
                var
              }
            )
          );
        }
      }
    }
  }

  public static void checkSelectedRecordsBelongsToSameObj(List<Id> recordIds) {
    Set<String> objectNames = new Set<String>();
    objectNames = BulkActionUtil.getObjectsFromRecordIds(recordIds);
    //if selected records belongs to diffrent objects, throw an exception
    if (objectNames.size() != 1) {
      throw new BulkActionsException(
        BulkActionErrorsAndMessages.NO_RECORDS_WITH_SAME_OBJECT
      );
    }
  }

  public static void validateInputParameters(
    String objectApiName,
    String fieldSetName
  ) {
    if (objectApiName == null || fieldSetName == null) {
      throw new BulkActionsException(
        BulkActionErrorsAndMessages.OBJECT_FIELD_SET_NULL_ERROR
      );
    }
  }
}
