import { LightningElement, api } from 'lwc';
import prevBtn from '@salesforce/label/c.PRM_Previous_Button';
import nextBtn from '@salesforce/label/c.PRM_Next_Button';
import fBtn from '@salesforce/label/c.PRM_First_Button';
import lBtn from '@salesforce/label/c.PRM_Last_Button';
export default class PRM_PaginatorBottom extends LightningElement {
    nextBtnLbl = nextBtn;
    prevBtnLbl = prevBtn;
    fBtnLbl = fBtn;
    lBtnLbl = lBtn;
    // Api considered as a reactive public property.  
    @api totalrecords;
    @api currentpage;
    @api pagesize;
    // Following are the private properties to a class.  
    lastpage = false;
    firstpage = false;
    // getter  
    get showFirstButton() {
        if (this.currentpage === 1) {
            return true;
        }
        return false;
    }
    // getter  
    get showLastButton() {
        if (Math.ceil(this.totalrecords / this.pagesize) === this.currentpage || !this.totalrecords) {
            return true;
        }
        return false;
    }
    //Fire events based on the button actions  
    handlePrevious() {
        this.dispatchEvent(new CustomEvent('previous'));
    }
    handleNext() {
        this.dispatchEvent(new CustomEvent('next'));
    }
    handleFirst() {
        this.dispatchEvent(new CustomEvent('first'));
    }
    handleLast() {
        this.dispatchEvent(new CustomEvent('last'));
    }
}