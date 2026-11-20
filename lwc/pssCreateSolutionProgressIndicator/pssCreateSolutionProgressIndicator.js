class pssCreateSolutionProgressIndicator extends NavigationMixin(LightningElement){}
// import { LightningElement } from 'lwc';

// // custom label
// import assessmentCompleted from '@salesforce/label/c.PSS_Assessment_Completed';
// import solutionSubmission from '@salesforce/label/c.PSS_SolutionSubmission';
// import intelReview from '@salesforce/label/c.PSS_IntelReviewSubmit';
// import offerPosted from '@salesforce/label/c.PSS_UpdateSubmissionApproval';
// import submissiontomarketplace from '@salesforce/label/c.PSS_SubmissiontoMarketplace';
// import solutionAssessment from '@salesforce/label/c.PSS_Solution_Assessment';
// import solutionSubmitted from '@salesforce/label/c.PSS_SolutionSubmitted';
// import viewSolutionButton from '@salesforce/label/c.PSS_View_Solution';
// import submittedSolutionButton from '@salesforce/label/c.PSS_Submitted_Solution';
// import messageOnSolutionSubmission from '@salesforce/label/c.PSS_Solution_Submited_Message';

// import { NavigationMixin } from 'lightning/navigation';

// /** The progress Indicator component shown when the solution is submitted.
//  *
//  * @example
//  * <!-- HTML component -->
//  * <c-pss-create-solution-progress-indicator></c-pss-create-solution-progress-indicator>
//  *
//  * @augments NavigationMixin
//  * @augments LightningElement
//  */
// class pssCreateSolutionProgressIndicator extends NavigationMixin(LightningElement) {
//   /** custom Labels:
//    * solutionAssessment-PSS_Solution_Assessment
//    * assessmentCompleted-PSS_Assessment_Completed
//    * intelReview-PSS_IntelReviewSubmit
//    * solutionSubmission-PSS_SolutionSubmitted
//    * offerPosted-PSS_UpdateSubmissionApproval
//    * submissiontomarketplace-PSS_SubmissiontoMarketplace
//    * viewSolutionButton-PSS_View_Solution
//    * submittedSolutionButton-PSS_Submitted_Solution
//    *
//    * @type {object}
//    * @private
//    */
//   label = {
//     solutionSubmitted,
//     solutionAssessment,
//     assessmentCompleted,
//     intelReview,
//     solutionSubmission,
//     offerPosted,
//     submissiontomarketplace,
//     viewSolutionButton,
//     submittedSolutionButton,
//     messageOnSolutionSubmission,
//   };

//   /** When View all Solution button is clicked helps to navigate to solution list view page.
//    *
//    * @private
//    *
//    */
//   navigateToAllSolution() {
//     this[NavigationMixin.Navigate]({
//       type: 'comm__namedPage',
//       attributes: {pageName: 'partner-solution-list'},
//     });
//   }

//   /** When View Submitted button is clicked the recordId is passed from the URL to this component.
//    * Based on the recordId the corresponding solution detail page is navigated.
//    *
//    *@private
//    */
//   navigateToSolution() {
//     const url = window.location.href;

//     const recordId = new URL(url).searchParams.get('recordId');

//     this[NavigationMixin.Navigate]({
//       type: 'comm__namedPage',
//       attributes: { pageName: 'solution-detail-page' },
//       state: { recordId },
//     });
//   }
// }

// export default pssCreateSolutionProgressIndicator;