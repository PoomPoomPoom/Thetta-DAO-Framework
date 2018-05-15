pragma solidity ^0.4.15;
import "./IMoneyflow.sol";
import "./IWeiReceiver.sol";

import "zeppelin-solidity/contracts/ownership/Ownable.sol";

contract DonationEndpoint is Ownable {
	function DonationEndpoint()public {

	}

	function withdrawDonations(address _to)public onlyOwner{
		_to.transfer(this.balance);
	}

	function() public payable{
		
	}
}

contract MoneyFlow is IMoneyflow, Ownable {
	DonationEndpoint public donationEndpoint;

	// by default - this is 0x0, please use setWeiReceiver method
	// this can be a WeiSplitter (top-down or unsorted)
	IWeiReceiver rootReceiver;

	function MoneyFlow()public{
		donationEndpoint = new DonationEndpoint();
	}

// IMoneyflow:
	function getDonationEndpointAddress()public constant returns(address){
		return address(donationEndpoint);
	}

	function withdrawDonations()public onlyOwner{
		assert(0x0!=address(rootReceiver));	// please set root receiver first

		donationEndpoint.withdrawDonations(rootReceiver);
	}

	// WARNING: this can be 0x0!
	// Do not send money here!
	function getRevenueEndpointAddress()public constant returns(address){
		return address(rootReceiver);
	}

// WeiReceivers:
	// receiver can be a splitter, fund or event task
	// _receiver can be 0x0!
	function setRootWeiReceiver(IWeiReceiver _receiver) public onlyOwner {
		rootReceiver = _receiver;
	}

///////////////////
	function() public {
		// non payable
	}
}
