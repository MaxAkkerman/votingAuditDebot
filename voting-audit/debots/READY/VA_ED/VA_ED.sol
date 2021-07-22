pragma ton-solidity ^0.45.0;
pragma AbiHeader expire;
pragma AbiHeader pubkey;
pragma AbiHeader time;

import "./Debot.sol";
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
interface IVotingAuditDebotACTMmenu {
    function preStart(address m_participant) external;

}

contract VotingAuditDebotED is Debot {

    //TODO for test only
    uint128 GRAMS_ADD = 700000000;
//    address choosenDADaddress = address.makeAddrStd(0, 0xc9d81bb29dcbdf531db223524ed8e5bdc8af2073100e29d809670b542c2b5022);
    address m_participant = address.makeAddrStd(0, 0x9f287f4355feb0d2d84ca3ff8819280b31161b3246486ca3fc67d77949b8f85f);
    //END
    bytes m_icon;

    address choosenDADaddress = address.makeAddrStd(0, 0x03f3f1930017d1f2820e5382d64d30aa10956600ad477fa679cbba6613ec0980);

    uint256 m_masterPubKey;
    uint256 m_masterSecKey;

    struct DistrictD {
        bytes name;
        uint256[] municipalBodiesArr;
        uint256[] votingPoolsArr;
    }

    mapping (uint256 => DistrictD) public districtD;
    uint256[] districtsD;


    struct MunicipalBodyD {
        bytes name;
        uint256[] votingPoolsArr;
    }

    mapping (uint256 => MunicipalBodyD) public MBD;
    uint256[] MBkeysD;


    struct VotingPoolD {
        bytes name;
        uint256[] votingCentersArr;
    }

    mapping (uint256 => VotingPoolD) public votingPoolD;
    uint256[] public votingPoolKeysD;

    function setIcon(bytes icon) public {
        require(msg.pubkey() == tvm.pubkey(), 100);
        tvm.accept();
        m_icon = icon;
    }

    function start() functionID(0x01) override public {
        startFetch();
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
        fetchDistricts();
        fetchMB();
        fetchVP();
        editDeAudit();
    }

    function fetchDistricts() public {
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

    function getDistrictData(uint256 curDistr) public {
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
        cp.municipalBodiesArr = municipalBodiesArr4Debot;
        cp.votingPoolsArr = votingPoolsArr4Debot;
        districtD[districtCurrentKeyD] = cp;
    }

    function fetchMB() public {
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

    function getMBData(uint256 curMB) public {
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
        mb.votingPoolsArr= votingPoolsArr4Debot;
        MBD[municipalBodyCurrentKeyD] = mb;
    }

    function fetchVP() public {
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

    function getVPData(uint256 curVP) public {
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
//        vp.votes = votes4Debot;
//        vp.votingCentersArr = votingCentersArronAddCandidateName4Debot;
        votingPoolD[votingPoolCurrentKeyD] = vp;
    }

    function editDeAudit() public {

        Menu.select("editDeauditDataMenu", "", [
            MenuItem("DEV fetch data", "",tvm.functionId(prestart)),
            MenuItem("DEV show data", "",tvm.functionId(devshow)),
            MenuItem("add district", "",tvm.functionId(onAddDistrictSetName)),
            MenuItem("Add candidate", "", tvm.functionId(onAddCandidateName)),
            MenuItem("add municipal body", "", tvm.functionId(onCurItemCheck)),
            MenuItem("add voting pool", "", tvm.functionId(onCurItemCheck)),
            MenuItem("add voting center", "", tvm.functionId(onCurItemCheck)),
            MenuItem("return to main menu", "", tvm.functionId(goToATdebot)),
            MenuItem("Quit", "", 0)
            ]);
    }

    function goToATdebot(uint32 index) public {
        IVotingAuditDebotACTMmenu(m_ATdebotAddress).preStart(m_participant);
    }


    function devshow(uint32 index) public {
        index = index;
        for(uint8 k = 0; k < districtsD.length; k++){
            uint256 curDT = districtsD[k];
            DistrictD dt = districtD[curDT];
            Terminal.print(0, format("districtD --- curDT: {},dt.name: {}", curDT,dt.name));
            }

        for(uint8 k = 0; k < MBkeysD.length; k++){
            uint256 curbm = MBkeysD[k];
            MunicipalBodyD mb = MBD[curbm];
            Terminal.print(0, format("MBkeysD --- MBkeysD[i]: {},mb.name: {}", curbm,mb.name));
        }
        for(uint8 k = 0; k < votingPoolKeysD.length; k++){
            uint256 curvp = votingPoolKeysD[k];
            VotingPoolD vp = votingPoolD[curvp];
            Terminal.print(0, format("MBkeysD --- curvp: {},mb.name: {}", curvp,vp.name));
        }

        DistrictD dt = districtD[1];

        uint256[] MBarr = dt.municipalBodiesArr;

        for(uint8 k = 0; k < MBarr.length; k++){
            uint256 curmbar = MBarr[k];
            MunicipalBodyD curStr = MBD[curmbar];
            Terminal.print(0,  format("curmbar: {}, curStr.name: {}", curmbar,curStr.name));

        }

        editDeAudit();
    }

    /*
        add district block
    */

    function onAddDistrictSetName(uint32 index) public {
        index = index;
        Terminal.input(tvm.functionId(setDistrictCall), "\nEnter district Name: \n", false);
    }

    function setDistrictCall(string value) public {
        bytes nameDistr = bytes(value);

        Terminal.print(0, format("\n***** Touched DeAuditData: {}, District name: {},grams for call: {}\n",choosenDADaddress,nameDistr,GRAMS_ADD));
        optional(uint256) pubkey;
        IParticipant(m_participant).addDistrict{
        abiVer : 2,
        extMsg : true,
        sign : true,
        pubkey : pubkey,
        time : uint64(now),
        expire: 0x123,
        callbackId : tvm.functionId(editDeAudit),
        onErrorId : tvm.functionId(someError)
        }(choosenDADaddress,nameDistr,GRAMS_ADD);

//        editDeAudit();
    }

/*
     Add candidate block
*/
    function onAddCandidateName(uint32 index) public {
        index = index;
        Terminal.input(tvm.functionId(setCandidateName), "\nEnter candidate Name: \n", false);
    }

    function setCandidateName(string value) public {
        bytes nameCandidate = bytes(value);
        Terminal.print(0, format("\n***** Touched DeAuditData: {}, Candidate name: {},grams for add: {}\n",choosenDADaddress,nameCandidate,GRAMS_ADD));
        optional(uint256) pubkey;
        IParticipant(m_participant).addCandidate{
        abiVer : 2,
        extMsg : true,
        sign : true,
        pubkey : pubkey,
        time : uint64(now),
        expire: 0x123,
        callbackId : tvm.functionId(editDeAudit),
        onErrorId : tvm.functionId(someError)
        }(choosenDADaddress,nameCandidate,GRAMS_ADD);

//        editDeAudit();
    }

/*
    checking menu item for add and set point - onCurItemCheck
*/
uint32 toundDistrictsID;
uint32 toundMBID;
uint32 toundVPID;

    function onCurItemCheck(uint32 index) public {
        index = index;
        if(index == 4){
            toundDistrictsID = 0x21;
        }else if(index == 5){
            toundDistrictsID = 0x11;
            toundMBID = 0x22;
        }else if(index == 6){
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

            string curVdata = format("*****\nDistrict name:{} District index: {}\n====\n",cp.name,curDistr);
            m_menu.push(MenuItem(curVdata,"",tvm.functionId(setTouchedDistrict)));

        }
        m_menu.push(MenuItem("Back to menu", "", tvm.functionId(prestart)));
        Menu.select("Choose district:", "",m_menu);
    }

uint256 curDistrIndexD;

    function setTouchedDistrict(uint32 index) public {
        index = index;
        curDistrIndexD = districtsD[index];
        Terminal.print(toundDistrictsID, format("----You touched District index: {}\n", curDistrIndexD));

    }

///take from MB

    function touchMB() functionID(0x11) public {
        MenuItem[] m_menu;
        DistrictD dt = districtD[curDistrIndexD];

        uint256[] MBarr = dt.municipalBodiesArr;

        for(uint8 k = 0; k < MBarr.length; k++){
            uint256 curmbar = MBarr[k];
            MunicipalBodyD curStr = MBD[curmbar];
            string curVdata = format("\n***** Municipal body name: {}, MB index: {}\n", curStr.name, curmbar);
            m_menu.push(MenuItem(curVdata,"",tvm.functionId(setTouchedMB)));
        }
        m_menu.push(MenuItem("Back to menu", "", tvm.functionId(prestart)));
        Menu.select("Choose Municipal bodyB:", "",m_menu);
    }

uint256 curMBIndexD;

    function setTouchedMB(uint32 index) public {
        index = index;
        DistrictD dt = districtD[curDistrIndexD];
        uint256[] MBarr = dt.municipalBodiesArr;
        uint256 curMBIndexD = MBarr[index];

//        Terminal.print(0,format("curMBIndexDByDistrict: {}\n\n",curMBIndexDByDistrict));
//        for(uint8 k = 0; k < MBkeysD.length; k++){
//            uint256 curMbd = MBkeysD[k];
//            if(curMBIndexDByDistrict == curMbd){
//
//                MunicipalBodyD cuSTR = MBD[curMBIndexDByDistrict];
//                curMBIndexD = MBkeysD[curMbd];
//                Terminal.print(0,format("\n\nmb name: {}, index: {}\n\n",cuSTR.name, curMBIndexDByDistrict));
//            }



//        }
        Terminal.print(toundMBID, format("\n ----You touched Municipal body index: {}\n", curMBIndexD));

    }


    ///take from Voting pool

    function touchVP() functionID(0x12) public {
        MenuItem[] m_menu;
        MunicipalBodyD dt = MBD[curMBIndexD];

        uint256[] VParray = dt.votingPoolsArr;
        for(uint8 i = 0; i < VParray.length; i++){

            uint256 curVP = VParray[i];
            VotingPoolD vp = votingPoolD[curVP];

            string curVdata = format("\n***** Voting pool name: {}, VP index: {}\n",vp.name, curVP);
            m_menu.push(MenuItem(curVdata,"",tvm.functionId(setTouchedVP)));

        }

        m_menu.push(MenuItem("Back to menu", "", tvm.functionId(prestart)));
        Menu.select("Choose Voting pool:", "",m_menu);
    }

uint256 curVPIndexD;

    function setTouchedVP(uint32 index) public {
        index = index;
        curVPIndexD = votingPoolKeysD[index];
        Terminal.print(toundVPID, format("\n ----You touched Voting pool index: {}\n", curVPIndexD));

    }

/*
     Add municipal body block
*/

    function onAddMB() functionID(0x21) public {
        Terminal.input(tvm.functionId(setMBname), "Enter Municipal body name: ", false);
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
        Terminal.input(tvm.functionId(setMBname), "Enter Voting pool name: ", false);
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

    function touchCurVotingVC() functionID(0x23) public {
        Terminal.input(tvm.functionId(setLocationVC), "Enter Voting Center name", false);
    }

bytes VCname;

    function setLocationVC(string value) public {
        VCname = bytes(value);
        Terminal.input(tvm.functionId(setVCname), "Enter Voting Center location", false);
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
