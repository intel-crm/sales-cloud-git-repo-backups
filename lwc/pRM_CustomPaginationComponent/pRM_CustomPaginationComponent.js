import { LightningElement, api } from 'lwc';

export default class PRM_CustomPaginationComponent extends LightningElement {
    @api pagesize = 0;
    @api currentpage = 0;
    @api prevpage = 0;
    @api nextpage = 0;

    handleNextPage() {
        this.currentpage += 1;
        return this.currentpage;
    }

    handlePrevPage() {
        this.currentpage -= 1;
        return this.currentpage;
    }

}