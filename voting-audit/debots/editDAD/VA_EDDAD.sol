pragma ton-solidity ^0.45.0;
pragma AbiHeader expire;
pragma AbiHeader pubkey;
pragma AbiHeader time;

import "../Debot.sol";
import "../Terminal.sol";
import "../Menu.sol";

interface IDeAuditData {
    function districtKeys() external returns (uint256[] districtKeys);
    function municipalBodyKeys() external returns (uint256[] municipalBodyKeys);
    function votingPoolKeys() external returns (uint256[] votingPoolKeys);

    function getVotingPool4Debot(uint256 votingPoolCurrentKey) external returns (
        bytes name4Debot,
        uint256[] votes4Debot,
        uint256[] votingCentersArr4Debot,
        uint256 votingPoolCurrentKeyD
    );
    function getMunicipalBody4Debot(uint256 municipalBodyCurrentKey) external returns (
        bytes name4Debot,
        uint256[] votes4Debot,
        uint256[] votingCentersArr4Debot,
        uint256[] votingPoolsArr4Debot,
        uint256 municipalBodyCurrentKeyD
    );
    function getDistrict4Debot(uint256 districtCurrentKey) external returns (
        bytes name4Debot,
        uint256[] votes4Debot,
        uint256[] votingCentersArr4Debot,
        uint256[] votingPoolsArr4Debot,
        uint256[] municipalBodiesArr4Debot,
        uint256 districtCurrentKeyD
    );
}
interface IParticipant {
    function addCandidate(address addressDeAuditData, bytes nameCandidate, uint128 grams) external;
    function addDistrict(address addressDeAuditData, bytes nameDistrict, uint128 grams) external;
    function addMunicipalBody(address addressDeAuditData, bytes nameMunicipalBody, uint256 indexDistrict, uint128 grams) external;
    function addVotingPool(address addressDeAuditData, bytes nameVotingPool, uint256 indexDistrict, uint256 indexMunicipalBody, uint128 grams) external;
    function addVotingCenter(address addressDeAuditData, bytes nameVotingCenter, bytes location, uint256 indexDistrict, uint256 indexMunicipalBody, uint256 indexVotingPool, uint128 grams) external;
}

contract ActmDebot is Debot {

    //TODO for test only
    uint128 GRAMS_ADD = 700000000;
    address DeAuditRoot = address.makeAddrStd(0, 0x96f39ad41e187a90bf45c7f80b370da825e188435a6cc1a4b8b4c42511f58616);
    address m_participant = address.makeAddrStd(0, 0x41df4fc897620c4ea227e472ae4298fb9760bc8c51acdac4876c940c513c8609);
    //END
    bytes m_icon;

    address choosenDADaddress;

    uint256 m_masterPubKey;
    uint256 m_masterSecKey;

    struct DistrictD {
        bytes name;
    }

    mapping (uint256 => DistrictD) public districtD;
    uint256[] districtsD;


    struct MunicipalBodyD {
        bytes name;
    }

    mapping (uint256 => MunicipalBodyD) public MBD;
    uint256[] MBkeysD;


    struct VotingPoolD {
        bytes name;
    }

    mapping (uint256 => VotingPoolD) public votingPoolD;
    uint256[] public votingPoolKeysD;

    function setIcon(bytes icon) public {
        require(msg.pubkey() == tvm.pubkey(), 100);
        tvm.accept();
        m_icon = icon;
    }

    function start() functionID(0x01) override public {
        editDeAudit();
    }
    function prestart(uint32 index) functionID(0x03) public {
        startFetch();
    }
    function startGlobal(address partAddress, address choosenDAD) public {
        choosenDADaddress = choosenDAD;
        m_participant = partAddress;
        startFetch();

    }
    function startFetch() public {
        editDeAudit();
        fetchDistricts();
        fetchMB();
        fetchVP();
    }

    function fetchDistricts() public view {
        optional(uint256) pubkey;
        IDeAuditData(choosenDADaddress).districtKeys{
        abiVer : 2,
        extMsg : true,
        sign : false,
        pubkey : pubkey,
        time : uint64(now),
        expire: 0x123,
        callbackId : tvm.functionId(SCfetchDistricts),
        onErrorId : tvm.functionId(someError)
        }();
    }

    function SCfetchDistricts(uint256[] districtKeys) public {
        districtsD = districtKeys;
        for(uint8 i = 0; i < districtKeys.length; i++){
            uint256 curDistrict = districtKeys[i];
            getDistrictData(curDistrict);
        }
    }

    function getDistrictData(uint256 curDistr) public view {
        optional(uint256) pubkey;
        IDeAuditData(choosenDADaddress).getDistrict4Debot{
        abiVer : 2,
        extMsg : true,
        sign : false,
        pubkey : pubkey,
        time : uint64(now),
        expire: 0x123,
        callbackId : tvm.functionId(SCchooseDistrict),
        onErrorId : tvm.functionId(someError)
        }(curDistr);

    }

    function SCchooseDistrict(
        bytes name4Debot,
        uint256[] votes4Debot,
        uint256[] votingCentersArr4Debot,
        uint256[] votingPoolsArr4Debot,
        uint256[] municipalBodiesArr4Debot,
        uint256 districtCurrentKeyD
    ) public {
        DistrictD cp = districtD[districtCurrentKeyD];
        cp.name = name4Debot;
        districtD[districtCurrentKeyD] = cp;
    }

    function fetchMB() public view {
        optional(uint256) pubkey;
        IDeAuditData(choosenDADaddress).municipalBodyKeys{
        abiVer : 2,
        extMsg : true,
        sign : false,
        pubkey : pubkey,
        time : uint64(now),
        expire: 0x123,
        callbackId : tvm.functionId(SCfetchMB),
        onErrorId : tvm.functionId(someError)
        }();
    }

    function SCfetchMB(uint256[] municipalBodyKeys) public {
        MBkeysD = municipalBodyKeys;
        for(uint8 i = 0; i < municipalBodyKeys.length; i++){
            uint256 curMB = municipalBodyKeys[i];
            getMBData(curMB);
        }
    }

    function getMBData(uint256 curMB) public view {
        optional(uint256) pubkey;
        IDeAuditData(choosenDADaddress).getMunicipalBody4Debot{
        abiVer : 2,
        extMsg : true,
        sign : false,
        pubkey : pubkey,
        time : uint64(now),
        expire: 0x123,
        callbackId : tvm.functionId(SCgetMBData),
        onErrorId : tvm.functionId(someError)
        }(curMB);

    }

    function SCgetMBData(
        bytes name4Debot,
        uint256[] votes4Debot,
        uint256[] votingCentersArr4Debot,
        uint256[] votingPoolsArr4Debot,
        uint256 municipalBodyCurrentKeyD
    ) public {
        MunicipalBodyD mb = MBD[municipalBodyCurrentKeyD];
        mb.name = name4Debot;
        MBD[municipalBodyCurrentKeyD] = mb;
    }

    function fetchVP() public view {
        optional(uint256) pubkey;
        IDeAuditData(choosenDADaddress).votingPoolKeys{
        abiVer : 2,
        extMsg : true,
        sign : false,
        pubkey : pubkey,
        time : uint64(now),
        expire: 0x123,
        callbackId : tvm.functionId(SCfetchVP),
        onErrorId : tvm.functionId(someError)
        }();
    }

    function SCfetchVP(uint256[] votingPoolKeys) public {
        votingPoolKeysD = votingPoolKeys;
        for(uint8 i = 0; i < votingPoolKeys.length; i++){
            uint256 curVP = votingPoolKeys[i];
            getVPData(curVP);
        }
    }

    function getVPData(uint256 curVP) public view {
        optional(uint256) pubkey;
        IDeAuditData(choosenDADaddress).getVotingPool4Debot{
        abiVer : 2,
        extMsg : true,
        sign : false,
        pubkey : pubkey,
        time : uint64(now),
        expire: 0x123,
        callbackId : tvm.functionId(SCgetVPData),
        onErrorId : tvm.functionId(someError)
        }(curVP);

    }
    function SCgetVPData(
        bytes name4Debot,
        uint256[] votes4Debot,
        uint256[] votingCentersArr4Debot,
        uint256 votingPoolCurrentKeyD
    ) public {
        VotingPoolD vp = votingPoolD[votingPoolCurrentKeyD];
        vp.name = name4Debot;
        votingPoolD[votingPoolCurrentKeyD] = vp;
    }

    function editDeAudit() public {

        Menu.select("editDeauditDataMenu", "", [
            MenuItem("DEV fetch data", "",0x03),
            MenuItem("add district", "",tvm.functionId(onAddDistrictSetName)),
            MenuItem("Add candidate", "", tvm.functionId(onAddCandidateName)),
            MenuItem("add municipal body", "", tvm.functionId(onCurItemCheck)),
            MenuItem("add voting pool", "", tvm.functionId(onCurItemCheck)),
            MenuItem("add voting center", "", tvm.functionId(onCurItemCheck)),
            MenuItem("return to main menu", "", 0x03),
            MenuItem("Quit", "", 0)
            ]);
    }


    /*
        add district block
    */

    function onAddDistrictSetName(uint32 index) public {
        Terminal.input(tvm.functionId(setDistrictCall), "Enter district Name", false);
    }

    function setDistrictCall(string value) public {
        bytes nameDistr = bytes(value);

        optional(uint256) pubkey;
        IParticipant(m_participant).addDistrict{
        abiVer : 2,
        extMsg : true,
        sign : true,
        pubkey : pubkey,
        time : uint64(now),
        expire: 0x123,
        callbackId : 0,
        onErrorId : tvm.functionId(someError)
        }(choosenDADaddress,nameDistr,GRAMS_ADD);

        editDeAudit();
    }

/*
     Add candidate block
*/
    function onAddCandidateName(uint32 index) public {
        Terminal.input(tvm.functionId(setCandidateName), "Enter candidate Name", false);
    }

    function setCandidateName(string value) public {
        bytes nameCandidate = bytes(value);

        optional(uint256) pubkey;
        IParticipant(m_participant).addCandidate{
        abiVer : 2,
        extMsg : true,
        sign : true,
        pubkey : pubkey,
        time : uint64(now),
        expire: 0x123,
        callbackId : 0,
        onErrorId : tvm.functionId(someError)
        }(choosenDADaddress,nameCandidate,GRAMS_ADD);

        editDeAudit();
    }

/*
    checking menu item for add and set point - onCurItemCheck
*/
uint32 toundDistrictsID;
uint32 toundMBID;
uint32 toundVPID;

    function onCurItemCheck(uint32 index) public {
        if(index == 3){
            toundDistrictsID = 0x21;
        }else if(index == 4){
            toundDistrictsID = 0x11;
            toundMBID = 0x22;
        }else if(index == 5){
            toundDistrictsID = 0x11;
            toundMBID = 0x12;
            toundVPID = 0x23;
        }
        touchDistricts();
    }

    ///take from district

    function touchDistricts() public {
        MenuItem[] m_menu;
        for(uint8 i = 0; i < districtsD.length; i++){
            uint256 curDistr = districtsD[i];
            DistrictD cp = districtD[curDistr];

            string curVdata = format("====\ncurDistr:{}\ndistrict name: {}\n====\n",curDistr,cp.name);
            m_menu.push(MenuItem(curVdata,"",tvm.functionId(setTouchedDistrict)));

        }
        m_menu.push(MenuItem("Back menu", "", tvm.functionId(prestart)));
        Menu.select("Choose district:", "",m_menu);
    }

uint256 curDistrIndexD;

    function setTouchedDistrict(uint32 index) public {
        curDistrIndexD = districtsD[index];
        Terminal.print(toundDistrictsID, format("cur distr id: {}", curDistrIndexD));

    }

///take from MB

    function touchMB() functionID(0x11) public {
        MenuItem[] m_menu;
//        curDistrIndexD

        for(uint8 i = 0; i < MBkeysD.length; i++){
            uint256 curMB = MBkeysD[i];
            MunicipalBodyD mb = MBD[curMB];

            string curVdata = format("====\ncur MB:{}\nMB name: {}\n====\n",curMB,mb.name);
            m_menu.push(MenuItem(curVdata,"",tvm.functionId(setTouchedMB)));

        }
        m_menu.push(MenuItem("Back menu", "", tvm.functionId(prestart)));
        Menu.select("Choose district:", "",m_menu);
    }

uint256 curMBIndexD;

    function setTouchedMB(uint32 index) public {
        curMBIndexD = MBkeysD[index];
        Terminal.print(toundMBID, format("cur mb id: {}", curMBIndexD));

    }


    ///take from Voting pool

    function touchVP() functionID(0x12) public {
        MenuItem[] m_menu;
        for(uint8 i = 0; i < votingPoolKeysD.length; i++){
            uint256 curVP = votingPoolKeysD[i];
            VotingPoolD vp = votingPoolD[curVP];

            string curVdata = format("====\ncur VP:{}\nVP name: {}\n====\n",curVP,vp.name);
            m_menu.push(MenuItem(curVdata,"",tvm.functionId(setTouchedVP)));

        }

        m_menu.push(MenuItem("Back menu", "", tvm.functionId(prestart)));
        Menu.select("Choose district:", "",m_menu);
    }

uint256 curVPIndexD;

    function setTouchedVP(uint32 index) public {
        curMBIndexD = votingPoolKeysD[index];
        Terminal.print(toundVPID, format("cur vp id: {}", curVPIndexD));

    }

/*
     Add municipal body block
*/

    function onAddMB() functionID(0x21) public {
        Terminal.input(tvm.functionId(setMBname), "Enter MB name", false);
    }

    function setMBname(string value) public {
        bytes MBname = bytes(value);

        optional(uint256) pubkey;
        IParticipant(m_participant).addMunicipalBody{
        abiVer : 2,
        extMsg : true,
        sign : true,
        pubkey : pubkey,
        time : uint64(now),
        expire: 0x123,
        callbackId : 0,
        onErrorId : tvm.functionId(someError)
        }(choosenDADaddress,MBname,curDistrIndexD,GRAMS_ADD);

        editDeAudit();
    }

/*
     Add Voting pool block
*/

    function touchCurVotingVP() functionID(0x22) public {
        Terminal.input(tvm.functionId(setMBname), "Enter VP name", false);
    }

    function setVPname(string value) public {
        bytes VPname = bytes(value);

        optional(uint256) pubkey;
        IParticipant(m_participant).addVotingPool{
        abiVer : 2,
        extMsg : true,
        sign : true,
        pubkey : pubkey,
        time : uint64(now),
        expire: 0x123,
        callbackId : 0,
        onErrorId : tvm.functionId(someError)
        }(choosenDADaddress,VPname,curDistrIndexD,curMBIndexD,GRAMS_ADD);

        editDeAudit();
    }

/*
     Add Voting center block
*/

    function touchCurVotingVC(uint32 index) functionID(0x23) public {
        Terminal.input(tvm.functionId(setLocationVC), "Enter VC name", false);
    }

bytes VCname;

    function setLocationVC(string value) public {
        VCname = bytes(value);
        Terminal.input(tvm.functionId(setVCname), "Enter VC location", false);
    }

    function setVCname(string value) public {
        bytes VClocation = bytes(value);

        optional(uint256) pubkey;
        IParticipant(m_participant).addVotingCenter{
        abiVer : 2,
        extMsg : true,
        sign : true,
        pubkey : pubkey,
        time : uint64(now),
        expire: 0x123,
        callbackId : 0,
        onErrorId : tvm.functionId(someError)
        }(choosenDADaddress,VCname,VClocation,curDistrIndexD,curMBIndexD,curVPIndexD,GRAMS_ADD);

        editDeAudit();
    }

/*
    utils
*/

    function someError(uint32 sdkError, uint32 exitCode) public {
        Terminal.print(0, format("sdkError: {}\nexitCOde:{}", sdkError, exitCode));
        Terminal.print(tvm.functionId(editDeAudit), "Back to menu...");
    }
    /// @notice Returns Metadata about DeBot.
    function getDebotInfo() public functionID(0xDEB) override view returns(
        string name, string version, string publisher, string caption, string author,
        address support, string hello, string language, string dabi, bytes icon
    ) {
        name = "Radiance Voting Audit DeBot ACTM";
        version = "0.1.0";
        publisher = "Radiance Team";
        caption = "DeBot for DeAudit by Radiance Team";
        author = "Radiance Team";
        support = address.makeAddrStd(0, 0x841288ed3b55d9cdafa806807f02a0ae0c169aa5edfe88a789a6482429756a94);
        hello = "That's debot for Voting Audit. Developed by Radiance Team";
        language = "en";
        dabi = m_debotAbi.get();
        icon = m_icon;
    }

    function getRequiredInterfaces() public view override returns (uint256[] interfaces) {
        return [ Terminal.ID ];
    }

}
