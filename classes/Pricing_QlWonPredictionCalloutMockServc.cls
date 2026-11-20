global class Pricing_QlWonPredictionCalloutMockServc implements HttpCalloutMock {
	global HttpResponse respond(HTTPRequest req){
        String respJSON = '{predictionDefinition=1ORD300000007Nq, predictions=({model={id=1OtD300000007OtKAI}, prediction={baseLine=47.46947686501335, middleValues=({columns=({columnName=CompetitorProductNameAndProductName, columnValue=1S AMD EPYC 3451 (32M Cache, 16C, 2.15GHz/2.45GHz), 100W,Intel® Xeon® Processor E3-1501M v6 (6M Cache, up to 3.60 GHz)}), value=3.6199320828985933}, {columns=({columnName=Intel Account Executive Email, columnValue=divyax.gangasaram@intel.com}), value=3.5736336111664855}, {columns=({columnName=Product Name, columnValue=Intel® Xeon® Processor E3-1501M v6 (6M Cache, up to 3.60 GHz)}), value=3.362413236983542}), other=28.232387872329205, smallTermCount=7, total=86.25784366839117}, prescriptions=(), status=Success}), settings={maxPrescriptions=-1, prescriptionImpactPercentage=0}}';
        HttpResponse res = new HttpResponse();
        res.setStatus('Ok');
        res.setStatusCode(201);
        res.setBody(respJSON);
        return res;
    }
}