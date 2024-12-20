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
