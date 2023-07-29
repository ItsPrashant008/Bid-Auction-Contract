import { Provider } from "@ethersproject/abstract-provider";
import { expect } from "chai";
import { BigNumber, Contract, Signer } from "ethers";
import { ethers } from "hardhat";

describe("Events Contract", () => {
    let owner: { address: any; };
    let Token;
    let hardhatToken: Contract;
    let addr1: { address: any; };
    let addr2: { address: string | Signer | Provider; };
    let startDate: BigNumber;
    let endDate: BigNumber;

    beforeEach(async () => {
        [owner, addr1, addr2] = await ethers.getSigners();
        Token = await ethers.getContractFactory("Lock");
        hardhatToken = await Token.deploy();
        startDate = ethers.BigNumber.from("1667901427");
        endDate = ethers.BigNumber.from("1668074227");
    });

    describe("For Item", () => {
        it("Should Check Item index increase and value same or not ", async () => {
            await hardhatToken.addBidItems("Prashant", 1667991092, 1667995092, 50);
            expect(await hardhatToken.itemIndex()).to.deep.equals(1);
            expect(await hardhatToken.items(1)).to.deep.equals([ethers.BigNumber.from("1"), "Prashant", owner.address, ethers.BigNumber.from("1667991092"), ethers.BigNumber.from("1667995092"), ethers.BigNumber.from("50"), false]);
        });

        it("Should Check Item iUpdate ", async () => {
            await hardhatToken.addBidItems("Prashant", 1667991092, 1667995092, 50);
            await hardhatToken.updateBidDetail(1, "Prashants", 1667991092, 1667995092, 55);
            
            expect(await hardhatToken.items(1)).to.deep.equals([ethers.BigNumber.from("1"), "Prashants", owner.address, ethers.BigNumber.from("1667991092"), ethers.BigNumber.from("1667995092"), ethers.BigNumber.from("55"), false]);
        });


    });

    describe("For Users", () => {
        it("Should Check User value same or not ", async () => {
            await hardhatToken.addBidItems("Prashant", 1667991092, 1667995092, 50);
            await hardhatToken.connect(addr1).addBidUser(1, 55);
            expect(await hardhatToken.bidusers(addr1.address, 1)).to.deep.equals([ethers.BigNumber.from("1"), "Prashant", ethers.BigNumber.from("55"), addr1.address]);
        });

        it("Should Check User update or not ", async () => {
            await hardhatToken.addBidItems("Prashant", 1667991092, 1667995092, 99);
            await hardhatToken.connect(addr1).addBidUser(1, 100);
            await hardhatToken.connect(addr1).updateUserBidAmount(1, 880);

            expect(await hardhatToken.bidusers(addr1.address, 1)).to.deep.equals([ethers.BigNumber.from("1"), "Prashant", ethers.BigNumber.from("880"), addr1.address]);
        });

    });

    describe("For Highest Bid", () => {
        it("Should Check Highest Bid index increase and value same or not ", async () => {
            await hardhatToken.addBidItems("Prashant", 1667991092, 1667995092, 50);
            expect(await hardhatToken.highestbids(1)).to.deep.equals([ethers.BigNumber.from("1"), owner.address, ethers.BigNumber.from("50"), false]);

            await hardhatToken.connect(addr1).addBidUser(1, 55);
            expect(await hardhatToken.highestbids(1)).to.deep.equals([ethers.BigNumber.from("1"), addr1.address, ethers.BigNumber.from("55"), false]);
        });
    });



});
