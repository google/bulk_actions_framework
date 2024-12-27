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
 * @group Builder
 * @description Builds `Invocable.Action.Result`
 */
@IsTest
public with sharing class BulkActionInvocableActionResultBuilder {
  private Map<String, Object> outputParameters;
  private Boolean success;
  private Invocable.Action action;
  private List<Invocable.Action.Error> errors;

  public BulkActionInvocableActionResultBuilder setOutputParameters(
    Map<String, Object> outputParameters
  ) {
    this.outputParameters = outputParameters;
    return this;
  }
  public BulkActionInvocableActionResultBuilder setSuccess(Boolean success) {
    this.success = success;
    return this;
  }
  public BulkActionInvocableActionResultBuilder setAction(
    Invocable.Action action
  ) {
    this.action = action;
    return this;
  }
  public BulkActionInvocableActionResultBuilder setErrors(
    List<Invocable.Action.Error> errors
  ) {
    this.errors = errors;
    return this;
  }

  public Invocable.Action.Result build() {
    Invocable.Action.Result result = (Invocable.Action.Result) JSON.deserialize(
      JSON.serialize(
        new Map<String, Object>{
          'action' => action,
          'errors' => errors,
          'success' => success,
          'outputParameters' => new Map<String, Object>()
        }
      ),
      Invocable.Action.Result.class
    );
    result.getOutputParameters().putAll(this.outputParameters);
    return result;
  }
}
