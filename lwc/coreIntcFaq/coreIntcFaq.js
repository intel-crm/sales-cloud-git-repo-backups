import { LightningElement, api, track } from 'lwc';
import { loadStyle } from 'lightning/platformResourceLoader';
import CoreINTC from '@salesforce/resourceUrl/Core_INTC';


/** 
 * A reusable component built on top of the Salesforce 
 * [lightning-accordion](https://developer.salesforce.com/docs/component-library/bundle/lightning-accordion/example) component
 * used to display Frequently Asked Questions.
 * 
 * The CoreIntcFaq component expects an array of [FaqSections]{@link FaqSection} to be passed to it.
 * Each [FaqSection]{@link FaqSection} must contain an array of questions, and may optionally
 * contain a title and description. 
 * 
 * @example
 * // This is example code for defining the faqs parameter in your JavaScript file. Note that you may need to track
 * // your faqs variable depending on how you are setting it. 
 * 
 * // In this example, key values are not set on the faqs and questions so they will be automatically generated.
 * faqs = [
 *   {
 *     title: "This is my first FAQ section header",
 *     questions: [
 *       {question: "This is my first question", answer: "This is my first answer"},
 *       {question: "This is my second question", answer: "This is my second answer"}
 *     ]
 *   },
 *   {
 *     title: "This is my second FAQ section header",
 *     description: "This is the description for the second FAQ section",
 *     questions: [
 *       {question: "This is my third question", answer: "This is my third answer"}
 *     ]
 *   }
 * ];
 * 
 * // In this example, key values are set on the faqs and questions.
 * faqs = [
 *   {
 *     title: "This is my first FAQ section header",
 *     description: "This is the description for the first FAQ section",
 *     key: '1234',
 *     questions: [
 *       {question: "This is my first question", answer: "This is my first answer", key: "9876"},
 *       {question: "This is my second question", answer: "This is my second answer", key: "8765"}
 *     ]
 *   },
 *   {
 *     title: "This is my second FAQ section header",
 *     key: '5678',
 *     questions: [
 *       {question: "This is my third question", answer: "This is my third answer", key: "7654"}
 *     ]
 *   }
 * ];
 * 
 * @example
 * <!-- HTML component example -->
 * <c-core-intc-faq faqs={faqs}></c-core-intc-faq>
 * 
 * @extends LightningElement
 * @property {FaqSection[]} faqs  An array of FAQ sections to display.
 */
class CoreIntcFaq extends LightningElement {
    // ******* API variables - defined in class properties *******
    @api
    get faqs() {
        return this._faqs;
    }
    set faqs(baseFaqs) {
        this._faqs = this.getFaqSections(baseFaqs);
    }




    // ******* Track variables ********
    /**
    * This is the array of [FaqSections]{@link FaqSection} actually displayed by the component.
    * This version exists to make sure that the key values used by the iterators exist.
    * It is generated through the [getFaqSections]{@link CoreIntcFaq#getFaqSections} method and
    * is set by the faqs setter.
    * @type {FaqSection[]}
    * @private
    */
    @track _faqs;

    /**
    * Generic object used to track the state of IF conditions
    * @type {Object}
    * @property {Object.showComponent} - Indicates if the component should be shown.
    * The component is hidden if there are no [FaqSections]{@link FaqSection}.
    * @private
    */
    @track
    ifs = {
        showComponent: false
    }




    // ******* Functions ********
    /**
   	* Called when the element is inserted into the DOM. Used to retrieve style overrides for 
    * the lightning-accordion.
    * @private
    */
    connectedCallback() {
        loadStyle(this, CoreINTC + '/general/component-styles.css')
            .catch(error => console.log("Error loading component-styles.css in coreIntcFaq - " + error.body.message));
    }



    /**
    * Adds key values to the FAQ questions if they are not already set.
  	* @param {FaqQuestion[]} baseFaqQuestions  The questions in the FAQ section.
    * @param {string} sectionKeyValue  The key value of the FAQ section that contains these questions.
    * @returns {FaqQuestion[]} An array of FAQ questions with the key value set.
    * @private
  	*/
    getFaqQuestions(baseFaqQuestions, sectionKeyValue) {
        // Loop through each FAQ question in the parameter array to check for a key value.
        let keyedFaqQuestions = baseFaqQuestions.map((faq, index) => {
            if (faq.key === undefined || faq.key === null) {
                // Need to add the key property
                return {
                    ...faq,
                    key: sectionKeyValue + 'faqQuestion_' + index
                };
            } else {
                // Key defined so just return the faq
                return faq;
            }
        });
        
        return keyedFaqQuestions;
    }



    /**
    * Adds key values to the FAQ sections if they are not already set.
  	* @param {FaqSection[]} baseFaqSections  The FAQ sections passed as a parameter to the component.
    * @returns {FaqSection[]} An array of FAQ sections with a key value set.
    * @private
  	*/
    getFaqSections(baseFaqSections) {
        // Loop through each FAQ section in the parameter array to check for a key value.
        let keyedFaqSections = baseFaqSections.map((faqSection, index) => {
            // Default a key
            let sectionKeyValue = 'faqSection_' + index;

            // Use the key property if it exists
            if (faqSection.key !== undefined && faqSection.key !== null) {
                sectionKeyValue = faqSection.key;
            }

            return {
                description: faqSection.description,
                key: sectionKeyValue,
                questions: this.getFaqQuestions(faqSection.questions, sectionKeyValue),
                title: faqSection.title
            };
        });

        // Check if any FAQ sections were created
        if (keyedFaqSections.length) {
            // Yes so show the component
            this.ifs.showComponent = true;
        }

        return keyedFaqSections;
    }
}
export default CoreIntcFaq;



// ********* Type Definitions ************
/**
 * Represents a question and answer used by the {@link CoreIntcFaq} component.
 * @typedef FaqQuestion
 * @property {string} answer  The text of the answer.
 * @property {string} [key]  The unique identifier for this question. It will be generated if not included.
 * @property {string} question  The text of the question.
 */

/**
 * Represents a collection of FAQ questions and answers used by the {@link CoreIntcFaq} component.
 * @typedef FaqSection
 * @property {string} [description]  The description of the section. Displayed under the title.
 * @property {string} [key]  The unique identifier for this section. It will be generated if not included.
 * @property {FaqQuestion[]} questions  An array of questions to be displayed in this section.
 * @property {string} [title]  The title of the section. Displayed as a header.
 */