pragma ton-solidity ^0.45.0;
pragma AbiHeader expire;
pragma AbiHeader pubkey;
pragma AbiHeader time;

import "../Debot.sol";
import "../Terminal.sol";
import "../AddressInput.sol";
import "../Menu.sol";

interface IDeAuditRoot {
    function getParticipantAddress(uint32 _answer_id,uint256 pubkeyParticipant) external returns (address value0);
    function keysDeAuditData() external returns (address[] keysDeAuditData);
    function getDeAuditParam4Debot(address keysDeAuditDataCurrent) external returns (
        address creator4Debot,
        bytes name4Debot,
        uint256 timeStart4Debot,
        uint256 colPeriod4Debot,
        uint256 valPeriod4Debot,
        uint256 colStake4Debot,
        uint256 valStake4Debot,
        address curDADkeyD
    );
}

interface IParticipant {
    function initVoteAddActionTeamMember(address participantAddr, uint128 grams) external;
    function initVoteRemoveActionTeamMember(address participantAddr, uint128 grams) external;
    function createDeAuditData(bytes nameDeAuditData,
        uint256 timeStart,
        uint256 colPeriod,
        uint256 valPeriod,
        uint128 colStake,
        uint128 valStake,
        uint128 grams) external;
    function initVoteDeAudut(address addrDeAuditData, uint128 grams) external;
}

interface IVotingAuditDebot {
    function preSstart(address m_participantC) external;
}
interface IVotingAuditDebotVL {
    function prestart(address m_participantC, address DeAuditRoot) external;
}

contract VotingAuditDebotACTMmenu is Debot {

    address m_VAdebotACTMmenuAddress;
    address m_actmAddress;
    address m_VotingAuditDebotVLaddress;
    address m_coreDebot;

    uint128 GRAMS_INIT_VOTE = 600000000;
    uint128 GRAMS_CREATE_DEAUDIT = 1100000000;

    address DeAuditRoot = address.makeAddrStd(0, 0x67d07ae1b594acad31b46fd6395fa2de8c64753b2545c26919d82383f9285aea);
    address m_participant = address.makeAddrStd(0, 0x9f287f4355feb0d2d84ca3ff8819280b31161b3246486ca3fc67d77949b8f85f);

    bytes m_icon;

    mapping(address => DeAuditParamD) public paramDeAuditD;
    address[] public keysDeAuditDataD;

    struct DeAuditParamD {
        address creator;
        bytes name;
        uint256 timeStart;
        uint256 colPeriod;
        uint256 valPeriod;
        uint256 colStake;
        uint256 valStake;
    }

    function setIcon(bytes icon) public {
        require(msg.pubkey() == tvm.pubkey(), 100);
        tvm.accept();
        m_icon = icon;
    }
    function preStart(address partic) public {
        m_participant = partic;
        fetchDAD();
        atmenu();
    }
    function pstart(uint32 index) public {
        fetchDAD();
        atmenu();
    }

    function start() public functionID(0x01) override {
        fetchDAD();
        atmenu();
    }
    function fetchDAD() public {
        optional(uint256) pubkey;
        IDeAuditRoot(DeAuditRoot).keysDeAuditData{
        abiVer : 2,
        extMsg : true,
        sign : false,
        pubkey : pubkey,
        time : uint64(now),
        expire: 0x123,
        callbackId : tvm.functionId(SCfetchDAD),
        onErrorId : tvm.functionId(someError)
        }();
    }

    function SCfetchDAD(address[] keysDeAuditData) public {
        keysDeAuditDataD = keysDeAuditData;

        for(uint8 i = 0; i < keysDeAuditDataD.length; i++){
            address curDAD = keysDeAuditDataD[i];
            getDADdata(curDAD);
        }
    }

    function getDADdata(address curDAD) public {

        optional(uint256) pubkey;
        IDeAuditRoot(DeAuditRoot).getDeAuditParam4Debot{
        abiVer : 2,
        extMsg : true,
        sign : false,
        pubkey : pubkey,
        time : uint64(now),
        expire: 0x123,
        callbackId : tvm.functionId(SCgetDADdata),
        onErrorId : tvm.functionId(someError)
        }(curDAD);
    }

    function SCgetDADdata(
        address creator4Debot,
        bytes name4Debot,
        uint256 timeStart4Debot,
        uint256 colPeriod4Debot,
        uint256 valPeriod4Debot,
        uint256 colStake4Debot,
        uint256 valStake4Debot,
        address curDADkeyD
    ) public {
        DeAuditParamD dd = paramDeAuditD[curDADkeyD];
        dd.creator = creator4Debot;
        dd.name = name4Debot;
        dd.timeStart = timeStart4Debot;
        dd.colPeriod = colPeriod4Debot;
        dd.valPeriod = valPeriod4Debot;
        dd.colStake = colStake4Debot;
        dd.valStake = valStake4Debot;
        paramDeAuditD[curDADkeyD] = dd;
    }


    function atmenu() public {
        Menu.select("Welcome to Action team menu", "", [
            MenuItem("DEV set core debot address", "", tvm.functionId(setACTMdebAddress)),
            MenuItem("dev refresh data", "",tvm.functionId(pstart)),
            MenuItem("Add member", "",tvm.functionId(initAddVoting)),
            MenuItem("Remove member", "", tvm.functionId(InitRemoveVoting)),
            MenuItem("createDeAuditData", "", tvm.functionId(enterDeAuditDataNameInput)),
//TODO отдельный дебот
            MenuItem("edit deAuditdata", "", tvm.functionId(editDeAudit)),
            MenuItem("init DeAudit", "", tvm.functionId(initDeauditDataMenuInput)),
            MenuItem("voting list", "", tvm.functionId(onToVLdebot)),
            MenuItem("return to main menu", "", tvm.functionId(goToCore)),
            MenuItem("Quit", "", 0)
            ]);
    }
/*
    set debot addreses
*/
    address m_EditDebot;

    function setACTMdebAddress(uint32 index) public {
        AddressInput.get(tvm.functionId(onsetDebadd), "dev set core deb adddress: ");
    }
    function onsetDebadd(address value) public {
        m_coreDebot = value;
        setVLdebAddress();
    }

    function setVLdebAddress() public {
        AddressInput.get(tvm.functionId(onsetVL), "dev set VL deb adddress: ");
    }
    function onsetVL(address value) public {
        m_VotingAuditDebotVLaddress = value;
        setEditDebaddress();
    }

    function setEditDebaddress() public {
        AddressInput.get(tvm.functionId(onsetEditDebaddress), "dev set EDIT deb adddress: ");
    }
    function onsetEditDebaddress(address value) public {
        m_EditDebot = value;
        start();
    }

/*
    go to core debot
*/
    function goToCore(uint32 index) public {
        IVotingAuditDebot(m_coreDebot).preSstart(m_participant);
    }


/*
    Voting list
*/

    function onToVLdebot(uint32 index) public {
        MenuItem[] m_menu;
        for(uint8 i = 0; i < keysDeAuditDataD.length; i++){
            address curDad = keysDeAuditDataD[i];
            DeAuditParamD dd = paramDeAuditD[curDad];

            string curVdata = format("====\nDAD name:{}\ndDAD address: {}\n====\n",dd.name,curDad);
            m_menu.push(MenuItem(curVdata,"",tvm.functionId(setDAD)));

        }
        m_menu.push(MenuItem("Back menu", "", tvm.functionId(pstart)));
        Menu.select("Choose DAD:", "",m_menu);
    }

address curDADaddress;

    function setDAD(uint32 index) public {
        curDADaddress = keysDeAuditDataD[index];
        goToVLdebot();
    }

    function goToVLdebot() public {
        IVotingAuditDebotVL(m_VotingAuditDebotVLaddress).prestart(m_participant, curDADaddress);
    }

/*
    Add/remove members
*/
    function initAddVoting(uint32 index) public {
        AddressInput.get(tvm.functionId(addMember_sendMSG), "Enter candidate address to add:");
    }
    function InitRemoveVoting(uint32 index) public {
        AddressInput.get(tvm.functionId(addMember_sendMSG), "Enter candidate address to remove:");
    }

    address m_memberAddress;

    function romoveMember_sendMSG(address value) public {
        m_memberAddress = value;

        optional(uint256) pubkey;
        IParticipant(m_participant).initVoteRemoveActionTeamMember{
        abiVer : 2,
        extMsg : true,
        sign : true,
        pubkey : pubkey,
        time : uint64(now),
        expire: 0x123,
        callbackId : 0,
        onErrorId : tvm.functionId(someError)
        }(m_memberAddress,GRAMS_INIT_VOTE);

        start();
    }

    function addMember_sendMSG(address value) public {
        m_memberAddress = value;

        optional(uint256) pubkey;
        IParticipant(m_participant).initVoteAddActionTeamMember{
        abiVer : 2,
        extMsg : true,
        sign : true,
        pubkey : pubkey,
        time : uint64(now),
        expire: 0x123,
        callbackId : 0,
        onErrorId : tvm.functionId(someError)
        }(m_memberAddress,GRAMS_INIT_VOTE);

        start();
    }

/*
    create de audit
*/
    bytes nameDeAudit;
    uint256 timeStart;
    uint256 colPeriod;
    uint256 valPeriod;
    uint128 colStake;
    uint128 valStake;

    function enterDeAuditDataNameInput(uint32 index) public {
        Terminal.input(tvm.functionId(enterDeAuditDataName), "Enter DeAudit Name", false);
    }

    function enterDeAuditDataName(string value) public {
        nameDeAudit = bytes(value);
        Terminal.input(tvm.functionId(enterDeAuditStartTime), "Enter start time of DeAudit (timestamp)", false);
    }

    function enterDeAuditStartTime(string value) public {
        uint res;
        bool status;
        (res, status) = stoi(value);
        timeStart = uint256(res);
        Terminal.input(tvm.functionId(enterDeAuditCollationPeriod), "Enter collation period of DeAudit (timestamp)", false);
    }

    function enterDeAuditCollationPeriod(string value) public {
        uint res;
        bool status;
        (res, status) = stoi(value);
        colPeriod = uint256(res);
        Terminal.input(tvm.functionId(enterDeAuditValidationPeriod), "Enter validation period of DeAudit (timestamp)", false);
    }

    function enterDeAuditValidationPeriod(string value) public {
        uint res;
        bool status;
        (res, status) = stoi(value);
        valPeriod = uint256(res);
        Terminal.input(tvm.functionId(enterDeAuditCollationStake), "Enter collation stake of DeAudit", false);
    }

    function enterDeAuditCollationStake(string value) public {
        uint res;
        bool status;
        (res, status) = stoi(value);
        colStake = uint128(res);
        Terminal.input(tvm.functionId(enterDeAuditValueStake), "Enter value of DeAudit stake", false);
    }

    function enterDeAuditValueStake(string value) public {
        uint res;
        bool status;
        (res, status) = stoi(value);
        valStake = uint128(res);
        callCreateDeAuditData();
    }

    function callCreateDeAuditData() public {
        optional(uint256) pubkey;
        IParticipant(m_participant).createDeAuditData{
        abiVer : 2,
        extMsg : true,
        sign : true,
        pubkey : pubkey,
        time : uint64(now),
        expire: 0x123,
        callbackId : 0,
        onErrorId : tvm.functionId(someError)
        }(
            nameDeAudit,
            timeStart,
            colPeriod,
            valPeriod,
            colStake,
            valStake,
            GRAMS_CREATE_DEAUDIT
        );
        start();
    }

/*
    init de Audit
*/
    function initDeauditDataMenuInput(uint32 index) public {
        AddressInput.get(tvm.functionId(initDeauditData), "Enter DeAudit Data address for Init:");
    }

    function initDeauditData(address value) public {
        optional(uint256) pubkey;
        IParticipant(m_participant).initVoteDeAudut{
        abiVer : 2,
        extMsg : true,
        sign : true,
        pubkey : pubkey,
        time : uint64(now),
        expire: 0x123,
        callbackId : 0,
        onErrorId : tvm.functionId(someError)
        }(
            value,
            GRAMS_INIT_VOTE
        );

        start();
    }

/*
    utils
*/

    function someError(uint32 sdkError, uint32 exitCode) public {
        Terminal.print(0, format("sdkError: {}\nexitCOde:{}", sdkError, exitCode));
        Terminal.print(0, "Back to menu...");
        start();
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
