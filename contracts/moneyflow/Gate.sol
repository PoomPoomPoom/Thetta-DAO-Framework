pragma solidity ^0.4.22;

import "./IMoneyflow.sol";

import "zeppelin-solidity/contracts/math/SafeMath.sol";
import "zeppelin-solidity/contracts/ownership/Ownable.sol";

import "../IDaoBase.sol";

/**
 * @title Gate (wei)
 * @dev Opens or closes the moneyflow
*/
contract Gate is Ownable, IWeiReceiver{
	// Simple Gate is open permanenlty; open/close implementation is for child;
	bool opened = true;
	IWeiReceiver child;
	IDaoBase dao;

	function Gate(IDaoBase _dao, address _child) public{
		child = IWeiReceiver(_child);
		dao = _dao;
	}

	function getPercentsMul100()constant public returns(uint){
		revert();
	}

	// TODO: this method is not provided in any interface 
	// should be removed
	function getChild() public constant returns(IWeiReceiver){
		return child;
	}

	function open() public onlyOwner{
		opened = true;
	}

	function close() public onlyOwner{
		opened = false;
	}

	function isOpen() public constant returns(bool){
		return opened;
	}

	function isNeedsMoney() constant public returns(bool){
		if(!isOpen()){
			return false;
		}else{
			IWeiReceiver c = IWeiReceiver(child);
			return c.isNeedsMoney();
		}
	}

	function getTotalWeiNeeded(uint _currentFlow) constant public returns(uint){
		if(!isOpen()){
			return 0;
		}else{
			IWeiReceiver c = IWeiReceiver(child);
			return c.getTotalWeiNeeded(_currentFlow);
		}
	}

	function getMinWeiNeeded() constant public returns(uint){
		if(!isOpen()){
			return 0;
		}else{
			IWeiReceiver c = IWeiReceiver(child);
			return c.getMinWeiNeeded();
		}
	}

	function processFunds(uint _currentFlow) public payable{
		require(isOpen());

		uint amount = _currentFlow;
		IWeiReceiver c = IWeiReceiver(child);
		uint needed = c.getTotalWeiNeeded(amount);
		c.processFunds.value(needed)(amount);
	}

	// use processFunds instead
	function() public {
		revert();
	}
}
