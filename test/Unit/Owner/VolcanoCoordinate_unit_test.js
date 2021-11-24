const { func } = require('assert-plus');
const { expect } = require('chai');

describe('VolcanoCoordinate Unit Test', function () {
    before(async function () {
        console.log('testing');
    });

    beforeEach(async function () {
        console.log('still testing');
    })

    it('Now entering body of test', async function () {
        console.log('Now in body of test');
        expect(0).to.equal(0);
    });
})
