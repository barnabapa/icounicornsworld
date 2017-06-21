pragma solidity ^0.4.4;


/// @title Migration Agent interface
contract MigrationAgent {
    function migrateFrom(address _from, uint256 _value);
}

/// @title ICO Unicorns . WORLD Token (ICOU) - crowdfunding code for ICO Unicorns . WORLD Token PreICO
contract ICOunicornsWorldpreICO {
    string public constant name = "preICO seed 1 ICO Unicorns . WORLD Token";
    string public constant symbol = "ICOU";
    uint8 public constant decimals = 18;  // 18 decimal places, the same as ETC/ETH.

    uint256 public constant tokenCreationRate = 1000;

    // The funding cap in weis.
    uint256 public constant tokenCreationCap = 60000 ether * tokenCreationRate;
    uint256 public constant tokenCreationMin = 1 ether * tokenCreationRate;

    uint256 public fundingStartBlock = 3904999;
	// 8 weeks
    uint256 public fundingEndBlock = 4192999;

    // The flag indicates if the ICOU contract is in Funding state.
    bool public funding = true;

    // Receives ETH and its own ICOU endowment.
    address public unicornsStronghold = 0x2b7913fCC943783B04d6dfBbb9fF9Ca9eb59cAEe;

    // Has control over token migration to next version of token.
    address public migrationMaster = 0x9dDF42E70313A0125CA964fF394CFfD1F005D249;


    // The current total token supply.
    uint256 totalTokens;
	uint256 bonusCreationRate;
    mapping (address => uint256) balances;
    mapping (address => uint256) balancesRAW;
    
    address public migrationAgent;
    uint256 public totalMigrated;

    event Transfer(address indexed _from, address indexed _to, uint256 _value);
    event Migrate(address indexed _from, address indexed _to, uint256 _value);
    event Refund(address indexed _from, uint256 _value);

    function ICOunicornsWorldpreICO() {

        if (unicornsStronghold == 0) throw;
        if (migrationMaster == 0) throw;
//        if (fundingStartBlock <= block.number) throw;
        if (fundingEndBlock   <= fundingStartBlock) throw;


     //   migrationMaster = _migrationMaster;
     //   unicornsStronghold = _unicornsStronghold;
     //   fundingStartBlock = _fundingStartBlock;
     //   fundingEndBlock = _fundingEndBlock;
    }

    /// @notice Transfer `_value` ICOU tokens from sender's account
    /// `msg.sender` to provided account address `_to`.
    /// @notice This function is disabled during the funding.
    /// @dev Required state: Operational
    /// @param _to The address of the tokens recipient
    /// @param _value The amount of token to be transferred
    /// @return Whether the transfer was successful or not
    function transfer(address _to, uint256 _value) returns (bool) {
        // Abort if not in Operational state.
        if (funding) throw;
//end of August + few first days of September
// - freez for about 60 days after crowdfunding
if ((msg.sender!=migrationMaster)&&(block.number < fundingEndBlock + 320000)) throw;

        var senderBalance = balances[msg.sender];
        if (senderBalance >= _value && _value > 0) {
            senderBalance -= _value;
            balances[msg.sender] = senderBalance;
            balances[_to] += _value;
            Transfer(msg.sender, _to, _value);
            return true;
        }
        return false;
    }

    function totalSupply() external constant returns (uint256) {
        return totalTokens;
    }

    function balanceOf(address _owner) external constant returns (uint256) {
        return balances[_owner];
    }

    // Token migration support:

    /// @notice Migrate tokens to the new token contract.
    /// @dev Required state: Operational Migration
    /// @param _value The amount of token to be migrated
    function migrate(uint256 _value) external {
        // Abort if not in Operational Migration state.
        if (funding) throw;
        if (migrationAgent == 0) throw;

        // Validate input value.
        if (_value == 0) throw;
        if (_value > balances[msg.sender]) throw;

        balances[msg.sender] -= _value;
        totalTokens -= _value;
        totalMigrated += _value;
        MigrationAgent(migrationAgent).migrateFrom(msg.sender, _value);
        Migrate(msg.sender, migrationAgent, _value);
    }

    /// @notice Set address of migration target contract and enable migration
	/// process.
    /// @dev Required state: Operational Normal
    /// @dev State transition: -> Operational Migration
    /// @param _agent The address of the MigrationAgent contract
    function setMigrationAgent(address _agent) external {
        // Abort if not in Operational Normal state.
        if (funding) throw;
        if (migrationAgent != 0) throw;
        if (msg.sender != migrationMaster) throw;
        migrationAgent = _agent;
    }

    function setMigrationMaster(address _master) external {
        if (msg.sender != migrationMaster) throw;
        if (_master == 0) throw;
        migrationMaster = _master;
    }
function() payable {
   if(funding){
   createICOU(msg.sender);
   }
}

     // Crowdfunding:

    /// @notice Create tokens when funding is active.
    /// @dev Required state: Funding Active
    /// @dev State transition: -> Funding Success (only if cap reached)
        function createICOU(address holder) payable {
        // Abort if not in Funding Active state.
        // The checks are split (instead of using or operator) because it is
        // cheaper this way.
        if (!funding) throw;
        if (block.number < fundingStartBlock) throw;
        if (block.number > fundingEndBlock) throw;

        // Do not allow creating 0 or more than the cap tokens.
        if (msg.value == 0) throw;
      //  if (msg.value > (tokenCreationCap - totalTokens) / tokenCreationRate)
       //   throw;
		
		if (block.number < fundingStartBlock) throw;	
		//bonus structure
		bonusCreationRate = tokenCreationRate;
	// seed cap bonus	
        if ((this.balance < 120 ether)&&(totalTokens < 2.3*120*tokenCreationMin)) bonusCreationRate = tokenCreationRate +500;

	//time bonuses
	// 1 block = 16-16.8 s

		// about 61 hours 2,6 day + week starting 21:08 UTC 20th June ending 10:08 UTC 30th June
		if (block.number < (fundingStartBlock + 13071 + 36000)){
		bonusCreationRate = bonusCreationRate + 200;
		} 
		// about 1 week 
		if (block.number < (fundingStartBlock + 72000)){
		bonusCreationRate = bonusCreationRate + 100;
		}
		
// Value bonus
			if (msg.value > 50 ether){
		bonusCreationRate = bonusCreationRate + 30;
		}	
			if (msg.value > 100 ether){
		bonusCreationRate = bonusCreationRate + 20;
		}	
			if (msg.value > 200 ether){
		bonusCreationRate = bonusCreationRate + 50;
		}	
			if (msg.value > 300 ether){
		bonusCreationRate = bonusCreationRate + 50;
		}	
			if (msg.value > 500 ether){
		bonusCreationRate = bonusCreationRate + 50;
		}	
			if (msg.value > 1000 ether){
		bonusCreationRate = bonusCreationRate + 50;
		}	
        	if (msg.value > 2000 ether){
		bonusCreationRate = bonusCreationRate + 50;
		}	
		 	if (msg.value > 3000 ether){
		bonusCreationRate = bonusCreationRate + 50;
		}
		    if (msg.value > 5000 ether){
		bonusCreationRate = bonusCreationRate + 50;
		}
			if (msg.value > 7000 ether){
		bonusCreationRate = bonusCreationRate + 50;
		}
		//+50% POSSIBLE MAXIMUM BONUS FOR VALUE
			if (msg.value > 10000 ether){
		bonusCreationRate = bonusCreationRate + 50;
		}
	
	 var numTokensRAW = msg.value * tokenCreationRate;

        var numTokens = msg.value * bonusCreationRate;
        totalTokens += numTokens;

        // Assign new tokens to the sender
        balances[holder] += numTokens;
        balancesRAW[holder] += numTokensRAW;
        // Log token creation event
        Transfer(0, holder, numTokens);
    }

    /// @notice Finalize crowdfunding
    /// @dev If cap was reached or crowdfunding has ended then:
    /// create ICOU for the community and developer,
    /// transfer ETH to the ICO Unicorns Stronghold address.
    /// @dev Required state: Funding Success
    /// @dev State transition: -> Operational Normal
    function Partial() external {
        // Abort if not Funding Success .
  if (this.balance < 5 ether) throw;
 
        // Transfer ETH to the ICO Unicorns . WORLD Fort address.
        unicornsStronghold.transfer(this.balance - 2 ether);
    }			
    function Partial23() external {
        // Abort if not Funding Success .
     if (totalTokens < tokenCreationMin) throw;
  
        // Transfer ETH to the ICO Unicorns . WORLD Fort address.
        unicornsStronghold.send(this.balance - 1 ether);
    }		
	
	
    function finalize() external {
        // Abort if not in Funding Success state.
        if (!funding) throw;
        if (totalTokens < tokenCreationMin) throw;
        if ((totalTokens<tokenCreationCap)&&(block.number <= fundingEndBlock)) throw;
		
        // Create additional ICOU for the community and developers around 14%
        uint256 percentOfTotal = 14;
        uint256 additionalTokens = 	totalTokens * percentOfTotal / (100);
        // Switch to Operational state. This is the only place this can happen.
        funding = false;

        totalTokens += additionalTokens;

        balances[migrationMaster] += additionalTokens;
        Transfer(0, migrationMaster, additionalTokens);
		//community tokens

        // Transfer ETH to the ICO Unicorns . WORLD Fort address.
        if (!unicornsStronghold.send(this.balance)) throw;
    }

    /// @notice Get back the ether sent during the funding in case the funding
    /// has not reached the minimum level.
    /// @dev Required state: Funding Failure
	// RAW is portion wihtout bonuses ;
    function refund() external {
        // Abort if not in Funding Failure state.
        if (!funding) throw;
        if (block.number <= fundingEndBlock) throw;
        if (totalTokens >= tokenCreationMin) throw;

        var ICOUValue = balances[msg.sender];
        var ICOUValueRAW = balancesRAW[msg.sender];
        if (ICOUValueRAW == 0) throw;
        balancesRAW[msg.sender] = 0;
        totalTokens -= ICOUValue;

        var ETHValue = ICOUValueRAW / tokenCreationRate;
        Refund(msg.sender, ETHValue);
        if (!msg.sender.send(ETHValue)) throw;
    }

function refundTRA() external {
        // Abort if not in Funding Failure state.
        if (!funding) throw;
        if (block.number <= fundingEndBlock) throw;
        if (totalTokens >= tokenCreationMin) throw;

        var ICOUValue = balances[msg.sender];
        var ICOUValueRAW = balancesRAW[msg.sender];
        if (ICOUValueRAW == 0) throw;
        balancesRAW[msg.sender] = 0;
        totalTokens -= ICOUValue;

        var ETHValue = ICOUValueRAW / tokenCreationRate;
        Refund(msg.sender, ETHValue);
        msg.sender.transfer(ETHValue);
    }



function ICOregulations() external returns(string) {
	return 'Regulations are present at website ICO Unicorns . WORLD by using this smartcontract you commit also that you accept and follow those rules';
}
}
