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
