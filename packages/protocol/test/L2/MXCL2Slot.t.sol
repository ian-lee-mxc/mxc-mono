// SPDX-License-Identifier: MIT
pragma solidity 0.8.27;

import "forge-std/src/Test.sol";
import "forge-std/src/console2.sol";

contract MXCL2Slot is Test {
    address mxcL2 = address(0x1000777700000000000000000000000000000001);
    uint256 MXCMainnetFork;
    bytes32 internal constant _ADMIN_SLOT =
        0xb53127684a568b3173ae13b9f8a6016e243e63b6e8ee1178d6a717850b5d6103;

    function setUp() public {
        MXCMainnetFork = vm.createFork("http://149.28.212.112:8545");
        vm.selectFork(MXCMainnetFork);
        vm.rollFork(508_360);
        assertEq(block.number, 508_360);
    }

    function testMXCL2Slot() external {
        verifyMXCL2Slot();
    }
    // slot_offset type varName contract TaikoL2
    // 0 uint8 _initialized -> Initializable
    // 0_1 bool __initializing -> Initializable
    // [1-50] uint[50] __gap -> ContextUpgradeable
    // 51 _owner -> OwnableUpgradeable
    // [52-100] uint[49] __gap -> OwnableUpgradeable
    // 101 address _pendingOwner -> Ownable2StepUpgradeable
    // [102-150] uint[49] __gap -> Ownable2StepUpgradeable
    // 151 address addressManager -> AddressResolver
    // [152-200] uint[49] __gap -> AddressResolver  AFTER: uint[25] [152-176]
    // 201_0 uint8 __reentry -> EssentialContract  AFTER:177_0
    // 201_1 uint8 __paused -> EssentialContract  AFTER: 177_1
    // 201_2 uint64 __lastUnpausedAt -> EssentialContract AFTER: 177_2
    // [202-250] uint[49] __gap -> EssentialContract AFTER: uint[23] [178-200]
    // 251 mapping[uint256,bytes32] l2Hashed -> TaikoL2 AFTER: 201
    // AFTER: 202 __deprecated_202
    // 252 bytes32 publicInputHash -> TaikoL2 AFTER: 203
    // 253_0 uint64 gasExcess -> TaikoL2
    // 253_8 uint64 lastSyncedBlock -> TaikoL2
    // 253_16 uint64 __deprecated1 -> TaikoL2
    // 253_24 uint64 __deprecated2 -> TaikoL2
    // 254 uint64 l1ChainId -> TaikoL2
    // 255 uint256[46] __gap -> TaikoL2

    // slot_offset type varName contract after MXCL2
    //0 uint8 _initialized -> Initializable
    //0_1 bool __initializing -> Initializable
    //1 uint256 _status  -> ReentrancyGuardUpgradeable
    //[2-50] uint256[49] gap -> ReentrancyGuardUpgradeable
    // [51-100] uint256[50] gap -> ContextUpgradeable
    //101 _owner -> OwneableUpgradeable empty
    // [102-150] uint256[49] gap -> OwnableUpgradeable
    //151 _addressManager -> AddressResolver
    //[152-200]  uint256[49] __gap -> AddressResolver
    //201 mapping _l2Hashes -> MXCL2
    //202 mapping _l1VerifiedBlocks -> MXCL2
    //203 bytes32 publicInputHash -> MXCL2
    //204 struct _eip1559Config -> MXCL2
    //205_0  uint64 parentTimestamp -> MXCL2
    //205_8 uint64 latestSyncedL1Height -> MXCL2;
    //205_16 uint64 gasExcess -> MXCL2
    //205_24 uint64 __reserved1 -> MXCL2
    //[206-250] uint256[45] __gap -> MXCL2
    function verifyMXCL2Slot() public {
        //        assert(_initialized == uint8(1));
        bytes32 _l2Hash0Data = vm.load(mxcL2, keccak256(abi.encode(uint256(1), 201))); // mapping
            // slot keccak256(abi.encode(key,mappingSlotNumber))
        assertEq(
            _l2Hash0Data,
            bytes32(0xcc4eea902d4a4a734e3e2902fb921ef72c6f73e80229f2cfd32335094e0a28bd)
        );
        address _admin = address(uint160(uint256(vm.load(mxcL2, _ADMIN_SLOT))));
        assertEq(_admin, address(0x75C4b5c07C6285cb2A14C512EeBaf4A6aed09BE6));

        for (uint256 i = 0; i < 250; i++) {
            readSlot(mxcL2, i, 0);
        }
    }

    function readSlot(
        address _contract,
        uint256 _slot,
        uint256 _offset
    )
        internal
        view
        returns (bytes32 data)
    {
        data = vm.load(_contract, bytes32(uint256(_slot)));
        console2.log("----MXCL2 slot:", _slot, "---offset", _offset);
        console2.logBytes32(data << 8 * _offset);
    }
}
