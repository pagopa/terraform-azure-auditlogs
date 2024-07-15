const appInsights = require('applicationinsights');
appInsights.setup(process.env.APPLICATIONINSIGHTS_CONNECTION_STRING).start();
const client = appInsights.defaultClient;
client.config.samplingPercentage=100;

module.exports = async function (context, req) {
    context.log('HTTP trigger function processed a request.');

    const name = req.body.name;
    const customPropertyFromBody = req.body.properties.customProperty;
    const requestCount = parseInt(req.body.requestCount);
    const audit = req.body.properties.audit;

    if (name) {
        context.res = {
            body: "Hello " + customPropertyFromBody
        };

        for (let i = 0; i < requestCount; i++) {
            const properties = {
                name: name,
                customProperty: customPropertyFromBody,
                audit: audit,
                requestIteration: i + 1,
                requestCount: requestCount
            };

            client.trackEvent({
                name: "HttpTrigger responded with name",
                properties: properties
            });
        }
    } else {
        context.res = {
            status: 400,
            body: "Please pass a name on the query string or in the request body"
        };
    }
}
