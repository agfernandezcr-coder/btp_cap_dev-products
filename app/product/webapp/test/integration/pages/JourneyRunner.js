sap.ui.define([
    "sap/fe/test/JourneyRunner",
	"logaligroup/product/test/integration/pages/ProductsList.gen",
	"logaligroup/product/test/integration/pages/ProductsObjectPage.gen",
	"logaligroup/product/test/integration/pages/ReviewsObjectPage.gen"
], function (JourneyRunner, ProductsListGenerated, ProductsObjectPageGenerated, ReviewsObjectPageGenerated) {
    'use strict';

    const runner = new JourneyRunner({
        launchUrl: sap.ui.require.toUrl('logaligroup/product') + '/test/flp.html#app-preview',
        pages: {
			onTheProductsListGenerated: ProductsListGenerated,
			onTheProductsObjectPageGenerated: ProductsObjectPageGenerated,
			onTheReviewsObjectPageGenerated: ReviewsObjectPageGenerated
        },
        async: true
    });

    return runner;
});

