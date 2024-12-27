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
