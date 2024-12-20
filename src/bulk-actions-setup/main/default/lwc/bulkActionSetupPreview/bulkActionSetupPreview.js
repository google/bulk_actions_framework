import { LightningElement, api } from "lwc";
import { getConstants } from "c/bulkActionSetupUtil";
import MEDIA from "@salesforce/resourceUrl/BulkActionResources";

//constants
const CONSTANTS = getConstants();

export default class BulkActionSetupPreview extends LightningElement {
  @api selectedStep;
  snapshot1_1;
  snapshot1_2;
  snapshot2_1;
  snapshot2_2;
  snapshot3_1;
  snapshot3_2;
  snapshot3_3;
  snapshot4_1;
  snapshot4_2;
  snapshot5_1;
  snapshot5_2;
  snapshot5_3;
  snapshot5_4;

  get isSelectStep1() {
    this.snapshot1_1 = MEDIA + "/step1_1.png";
    this.snapshot1_2 = MEDIA + "/step1_2.png";
    return this.selectedStep === CONSTANTS.STEPS.STEP1;
  }

  get isSelectStep2() {
    this.snapshot2_1 = MEDIA + "/step2_1.png";
    this.snapshot2_2 = MEDIA + "/step2_2.png";
    return this.selectedStep === CONSTANTS.STEPS.STEP2;
  }

  get isSelectStep3() {
    this.snapshot3_1 = MEDIA + "/step3_1.png";
    this.snapshot3_2 = MEDIA + "/step3_2.png";
    this.snapshot3_3 = MEDIA + "/step3_3.png";
    return this.selectedStep === CONSTANTS.STEPS.STEP3;
  }

  get isSelectStep4() {
    this.snapshot4_1 = MEDIA + "/step4_1.png";
    this.snapshot4_2 = MEDIA + "/step4_2.png";
    return this.selectedStep === CONSTANTS.STEPS.STEP4;
  }

  get isSelectStep5() {
    this.snapshot5_1 = MEDIA + "/step5_1.png";
    this.snapshot5_2 = MEDIA + "/step5_2.png";
    this.snapshot5_3 = MEDIA + "/step5_3.png";
    this.snapshot5_4 = MEDIA + "/step5_4.png";
    return this.selectedStep === CONSTANTS.STEPS.STEP5;
  }

  get isSelectStep6() {
    return this.selectedStep === CONSTANTS.STEPS.STEP6;
  }
}
