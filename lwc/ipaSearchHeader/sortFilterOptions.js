import relevance from '@salesforce/label/c.PMP_SortByRelevance';
import featured from '@salesforce/label/c.PMP_SortByFeatured';
import partnerTier from '@salesforce/label/c.PMP_SortByPartnerTier';
import newlyAdded from '@salesforce/label/c.PMP_SortByNew';

// TODO add "Sort by: " and alpha label
let sortBy = 'Sort by: ';
let alpha = 'Alphabetically, A-Z';

export default [
    { label: `${sortBy} ${alpha}`,          value: 'alphabetical' },
    { label: `${sortBy} ${relevance}`,      value: 'relevance' },
    { label: `${sortBy} ${featured}`,       value: 'featured' },
    { label: `${sortBy} ${partnerTier}`,    value: 'partner' },
    { label: `${sortBy} ${newlyAdded}`,     value: 'new' }
];