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
