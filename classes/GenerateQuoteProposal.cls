public without sharing class GenerateQuoteProposal {
    
    public String save(QuoteProposalModel context) {
        //system.debug('JSON.serialize(context)==>'+JSON.serialize(context));
        return SBQQ.ServiceRouter.save('SBQQ.QuoteDocumentAPI.Save', JSON.serialize(context));
    }
    public String save(List<QuoteProposalModel> context) {
        //system.debug('JSON.serialize(context)==>'+JSON.serialize(context));
        return SBQQ.ServiceRouter.save('SBQQ.QuoteDocumentAPI.Save', JSON.serialize(context));
    }
}