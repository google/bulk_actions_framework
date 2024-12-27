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
 * @group Test Utility
 * @description Builds sample data for Bulk Actions test classes
 */
@SuppressWarnings(
  'PMD.UnitTestMethodNamingConventions,PMD.ApexUnitTestClassShouldHaveAsserts'
)
@IsTest
public with sharing class BulkActionsTestDataUtil {
  private static final String CASE_OBJ_PREFIX = '500';
  private static final String CONTACT_OBJ_PREFIX = '003';

  private static Contact conObject = new Contact(
    FirstName = 'John',
    LastName = 'Doe'
  );

  @IsTest
  public static Bulk_Action_Configuration__mdt getConfig() {
    return new Bulk_Action_Configuration__mdt(
      DeveloperName = 'Bulk Action Demo',
      MasterLabel = 'Test_Config',
      Eval_Flow_API_Name__c = 'Test Flow Eval',
      Action_Flow_API_Name__c = 'Test Flow',
      Preview_Screen_Button_Name__c = 'Test',
      Preview_Screen_Field_Set_API_Name__c = 'Test FS'
    );
  }

  @IsTest
  public static Case getSampleCase() {
    return new Case(
      Id = CASE_OBJ_PREFIX + '0'.repeat(12),
      ContactId = conObject.Id,
      Description = 'Test Case'
    );
  }

  @IsTest
  public static Contact getSampleContact() {
    return new Contact(
      Id = CONTACT_OBJ_PREFIX + '0'.repeat(12),
      FirstName = 'First Name',
      LastName = 'Last Name',
      Email = 'Test@test.com'
    );
  }

  @IsTest
  public static Invocable.Action.Result getValidInvocableResult() {
    return new BulkActionInvocableActionResultBuilder()
      .setSuccess(true)
      .setOutputParameters(
        new Map<String, Object>{
          BulkActionConstants.EVAL_FLOW_OP_IS_VALID => true
        }
      )
      .build();
  }

  @IsTest
  public static Invocable.Action.Result getInvalidInvocableResultForIsValidFlag() {
    return new BulkActionInvocableActionResultBuilder()
      .setSuccess(true)
      .setOutputParameters(
        new Map<String, Object>{
          BulkActionConstants.EVAL_FLOW_OP_IS_VALID => 'true',
          BulkActionConstants.EVAL_FLOW_OP_MSG => 'test'
        }
      )
      .build();
  }

  @IsTest
  public static Invocable.Action.Result getInvalidInvocableResultForOutputMessageVar() {
    return new BulkActionInvocableActionResultBuilder()
      .setSuccess(true)
      .setOutputParameters(
        new Map<String, Object>{
          BulkActionConstants.EVAL_FLOW_OP_IS_VALID => true,
          BulkActionConstants.EVAL_FLOW_OP_MSG => 123
        }
      )
      .build();
  }

  @IsTest
  public static BulkActionTable getSampleTable() {
    return new BulkActionTable(
      'Case',
      new List<Id>{ getSampleCase().Id },
      getSampleColumns(),
      getSampleRows()
    );
  }

  @IsTest
  private static List<BulkActionTable.Column> getSampleColumns() {
    BulkActionTable.Column col = new BulkActionTable.Column();
    col.label = 'Id';
    col.apiName = 'Id';
    col.fieldDataType = 'text';
    return new List<BulkActionTable.Column>{ col };
  }

  @IsTest
  private static List<BulkActionTable.Row> getSampleRows() {
    BulkActionTable.Row row = new BulkActionTable.Row();
    row.displayRecord = getSampleCase();
    return new List<BulkActionTable.Row>{ row };
  }
}
