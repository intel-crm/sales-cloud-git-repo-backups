import { mockTaxonomy } from '../objects/taxonomy';

export default {

    fetchTaxonomyData: async () => {
        let parsedData = {};
        try {
            parsedData = JSON.parse(window.MOCKDATA_TAXONOMY);
        } catch(e) {
            console.log('PARSE DID NOT WORK', e);
            parsedData = mockTaxonomy();
        }
        return parsedData;
    },

}