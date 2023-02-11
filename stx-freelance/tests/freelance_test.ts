
import { Clarinet, Tx, Chain, Account, types } from 'https://deno.land/x/clarinet@v1.3.1/index.ts';
import { assertEquals } from 'https://deno.land/std@0.170.0/testing/asserts.ts';

const contract_name = "freelance"
const token_adress = "SP27BB1Y2DGSXZHS7G9YHKTSH6KQ6BD3QG0AN3CR9.vibes-token"
const hv_wallet = "STNHKEPYEPJ8ET55ZZ0M5A34J0R3N5FM2CMMMAZ6"

Clarinet.test({
    name: "Ensure that job can be added and hv fee & escrow amount is transferred ",
    async fn(chain: Chain, accounts: Map<string, Account>) {
        let deployer = accounts.get("deployer")!;
        let wallet_1 = accounts.get("wallet_1")!;
        let wallet_2 = accounts.get("wallet_2")!;

        const job_cost = 10000000
        const hv_fee = (job_cost * 5)/100
        const freelancer_address = types.principal(wallet_2.address)

        let block = chain.mineBlock([
           Tx.contractCall(
                contract_name,
                "add-job-in-stx",
                [types.uint(101), types.uint(job_cost), freelancer_address],
                wallet_1.address
            ),

            Tx.contractCall(
                contract_name,
                "add-job-in-stx",
                [types.uint(101), types.uint(job_cost), freelancer_address],
                wallet_1.address
            ),
        ]);
        assertEquals(block.receipts.length, 2);
        assertEquals(block.height, 2);

        block.receipts[0].result.expectOk().expectBool(true);
        block.receipts[0].events.expectSTXTransferEvent(hv_fee, wallet_1.address, hv_wallet);
        block.receipts[0].events.expectSTXTransferEvent(10000000, wallet_1.address, `${deployer.address}.freelance`);

        // job with same id can not be added by the same wallet
        block.receipts[1].result.expectErr().expectUint(200);
        block = chain.mineBlock([
            /*
             * Add transactions with:
             * Tx.contractCall(...)
            */
        ]);
        assertEquals(block.receipts.length, 0);
        assertEquals(block.height, 3);
    },
});
