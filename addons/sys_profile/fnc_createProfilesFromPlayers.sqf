#include "\x\alive\addons\sys_profile\script_component.hpp"
SCRIPT(createProfilesFromPlayers);

/* ----------------------------------------------------------------------------
Function: ALIVE_fnc_createProfilesFromPlayers

Description:
Create profiles for all players on the map that don't have profiles

Parameters:

Returns:

Examples:
(begin example)
// get profiles from all players
[] call ALIVE_fnc_createProfilesFromPlayers;
(end)

See Also:

Author:
ARJay
---------------------------------------------------------------------------- */

private ["_state","_uid","_player","_debug","_players","_entityCount","_playerProfiles","_profileIndex","_registeredProfile","_group","_leader","_units","_unitClasses","_positions","_ranks",
"_damages","_unitCount","_profileID","_unit","_eventID","_profileID","_position","_side","_existingPlayers","_existingProfile","_profileEntity","_uuid","_index","_playerIndexes"];


_state = _this select 0;
_uid = if(count _this > 1) then {_this select 1} else {""};
_player = if(count _this > 2) then {_this select 2} else {objNull};
_debug = if(count _this > 3) then {_this select 3} else {false};

_players = [];
if (isMultiplayer) then {
    _players = allPlayers;
} else {
    _players = [player];
};

_playerProfiles = [ALIVE_profileHandler, "getPlayerEntities"] call ALIVE_fnc_profileHandler;
_profileIndex = [ALIVE_profileHandler,"getPlayerIndex"] call ALIVE_fnc_profileHandler;

_entityCount = count (_playerProfiles select 1);

// DEBUG -------------------------------------------------------------------------------------
if(_debug) then {
    ["Player profiler - State: %1",_state] call ALiVE_fnc_dump;
    ["Player profiler - Current Entity Count: %1",_entityCount] call ALiVE_fnc_dump;
    ["Player profiler - UID: %1",_uid] call ALiVE_fnc_dump;
    ["Player profiler - Player: %1",_player] call ALiVE_fnc_dump;
    ["Player profiler - Player Group: %1",group _player] call ALiVE_fnc_dump;
    ["Player profiler - Player Group Units: %1",units group _player] call ALiVE_fnc_dump;
};

if(_uid in (_profileIndex select 1)) then {
    _registeredProfile = [_profileIndex, _uid] call ALIVE_fnc_hashGet;
};

if!(isNil "_registeredProfile") then {

    //["Player profiler - Registered profile exists"] call ALiVE_fnc_dump;

    switch(_state) do {
        case "CONNECT":{

        };
        case "DISCONNECT":{

            //["Player profiler - Registered profile found, remove disconnecting player from profile"] call ALiVE_fnc_dump;

            _profileEntity = _registeredProfile;
            _group = _profileEntity select 2 select 13;
            _profileID = _profileEntity select 2 select 4;
            _units = units _group;
            _existingPlayers = [];

            [_profileIndex, _uid] call ALIVE_fnc_hashRem;

            {
                _unit = _x;
                if(isPlayer _unit) then {
                    _uuid = getPlayerUID _unit;
                    if(_uuid != _uid) then {
                        _existingPlayers pushback _uuid;
                        //["Player profiler - found another player in this group: %1",_unit] call ALiVE_fnc_dump;
                    }else{
                        //["Player profiler - found disconnecting player in this group: %1",_unit] call ALiVE_fnc_dump;
                    };
                };
            } forEach _units;

            // there are existing players in this group check if they are profiled
            if(count _existingPlayers > 0) then {
                //["Player profiler - other players in group, wait until disconnecting player is null and update"] call ALiVE_fnc_dump;

                _leader = leader _group;

                _unitClasses = [];
                _positions = [];
                _ranks = [];
                _damages = [];
                _unitCount = 0;

                {
                    _unit = _x;
                    _unitClasses pushback (typeOf _x);
                    _positions pushback (getPosATL _x);
                    _ranks pushback (rank _x);
                    _damages pushback (getDammage _x);

                    _unitCount = _unitCount + 1;

                } foreach (_units);

                _position = getPosATL _leader;

                [_profileEntity, "unitClasses", _unitClasses] call ALIVE_fnc_profileEntity;
                [_profileEntity, "position", _position] call ALIVE_fnc_profileEntity;
                [_profileEntity, "despawnPosition", _position] call ALIVE_fnc_profileEntity;
                [_profileEntity, "positions", _positions] call ALIVE_fnc_profileEntity;
                [_profileEntity, "damages", _damages] call ALIVE_fnc_profileEntity;
                [_profileEntity, "ranks", _ranks] call ALIVE_fnc_profileEntity;
                [_profileEntity, "isPlayer", true] call ALIVE_fnc_profileEntity;
                [_profileEntity, "leader", _leader] call ALIVE_fnc_hashSet;
                [_profileEntity, "units", _units] call ALIVE_fnc_hashSet;
                [_profileEntity, "active", true] call ALIVE_fnc_hashSet;

                // DEBUG -------------------------------------------------------------------------------------
                if(_debug) then {
                    _players = [ALIVE_profileHandler, "getPlayerEntities"] call ALIVE_fnc_profileHandler;
                    _players call ALIVE_fnc_inspectHash;
                    _index = [ALIVE_profileHandler, "getPlayerIndex"] call ALIVE_fnc_profileHandler;
                    _index call ALIVE_fnc_inspectHash;
                    ["Player profiler - Remove disconnected player profile complete"] call ALiVE_fnc_dump;
                };
                // DEBUG -------------------------------------------------------------------------------------

            }else{
                //["Player profiler - No players found removing profile.."] call ALiVE_fnc_dump;
                [ALIVE_profileHandler, "unregisterProfile", _profileEntity] call ALIVE_fnc_profileHandler;

                // DEBUG -------------------------------------------------------------------------------------
                if(_debug) then {
                    _players = [ALIVE_profileHandler, "getPlayerEntities"] call ALIVE_fnc_profileHandler;
                    _players call ALIVE_fnc_inspectHash;
                    _index = [ALIVE_profileHandler, "getPlayerIndex"] call ALIVE_fnc_profileHandler;
                    _index call ALIVE_fnc_inspectHash;
                    ["Player profiler - Remove disconnected player profile complete"] call ALiVE_fnc_dump;
                };
                // DEBUG -------------------------------------------------------------------------------------
            }

        };
        case "KILLED":{
            //["Player profiler - Registered profile found, remove killed player from profile"] call ALiVE_fnc_dump;

            _profileEntity = _registeredProfile;
            _group = _profileEntity select 2 select 13;
            _profileID = _profileEntity select 2 select 4;
            _units = units _group;
            _existingPlayers = [];

            [_profileIndex, _uid] call ALIVE_fnc_hashRem;

            {
                _unit = _x;
                if(isPlayer _unit) then {
                    _uuid = getPlayerUID _unit;
                    if(_uuid != _uid) then {
                        _existingPlayers pushback _uuid;
                        //["Player profiler - found another player in this group: %1",_unit] call ALiVE_fnc_dump;
                    }else{
                        //["Player profiler - found disconnecting player in this group: %1",_unit] call ALiVE_fnc_dump;
                    };
                };
            } forEach _units;

            // there are existing players in this group check if they are profiled
            if(count _existingPlayers > 0) then {
                //["Player profiler - other players in group, wait until disconnecting player is null and update"] call ALiVE_fnc_dump;

                _leader = leader _group;

                _unitClasses = [];
                _positions = [];
                _ranks = [];
                _damages = [];
                _unitCount = 0;

                {
                    _unit = _x;
                    _unitClasses pushback (typeOf _x);
                    _positions pushback (getPosATL _x);
                    _ranks pushback (rank _x);
                    _damages pushback (getDammage _x);

                    _unitCount = _unitCount + 1;

                } foreach (_units);

                _position = getPosATL _leader;

                [_profileEntity, "unitClasses", _unitClasses] call ALIVE_fnc_profileEntity;
                [_profileEntity, "position", _position] call ALIVE_fnc_profileEntity;
                [_profileEntity, "despawnPosition", _position] call ALIVE_fnc_profileEntity;
                [_profileEntity, "positions", _positions] call ALIVE_fnc_profileEntity;
                [_profileEntity, "damages", _damages] call ALIVE_fnc_profileEntity;
                [_profileEntity, "ranks", _ranks] call ALIVE_fnc_profileEntity;
                [_profileEntity, "isPlayer", true] call ALIVE_fnc_profileEntity;
                [_profileEntity, "leader", _leader] call ALIVE_fnc_hashSet;
                [_profileEntity, "units", _units] call ALIVE_fnc_hashSet;
                [_profileEntity, "active", true] call ALIVE_fnc_hashSet;

                // DEBUG -------------------------------------------------------------------------------------
                if(_debug) then {
                    _players = [ALIVE_profileHandler, "getPlayerEntities"] call ALIVE_fnc_profileHandler;
                    _players call ALIVE_fnc_inspectHash;
                    _index = [ALIVE_profileHandler, "getPlayerIndex"] call ALIVE_fnc_profileHandler;
                    _index call ALIVE_fnc_inspectHash;
                    ["Player profiler - Remove disconnected player profile complete"] call ALiVE_fnc_dump;
                };
                // DEBUG -------------------------------------------------------------------------------------

            }else{
                //["Player profiler - No players found removing profile.."] call ALiVE_fnc_dump;
                [ALIVE_profileHandler, "unregisterProfile", _profileEntity] call ALIVE_fnc_profileHandler;

                // DEBUG -------------------------------------------------------------------------------------
                if(_debug) then {
                    _players = [ALIVE_profileHandler, "getPlayerEntities"] call ALIVE_fnc_profileHandler;
                    _players call ALIVE_fnc_inspectHash;
                    _index = [ALIVE_profileHandler, "getPlayerIndex"] call ALIVE_fnc_profileHandler;
                    _index call ALIVE_fnc_inspectHash;
                    ["Player profiler - Remove disconnected player profile complete"] call ALiVE_fnc_dump;
                };
                // DEBUG -------------------------------------------------------------------------------------
            }
        };
        case "RESPAWN":{

        };
    };


}else{

    //["Player profiler - Registered profile does not exist"] call ALiVE_fnc_dump;

    switch(_state) do {
        case "INIT":{

            // pick up players in single player
            //if!(isMultiplayer) then {
                {
                    _group = group _x;
                    _leader = leader _group;
                    _units = units _group;
                    _unitClasses = [];
                    _positions = [];
                    _ranks = [];
                    _damages = [];
                    _unitCount = 0;
                    _profileID = format["player_%1",_entityCount];

                    if(_leader getVariable ["profileID",""] == "") then {

                        {
                            _unit = _x;
                            _unitClasses pushback (typeOf _x);
                            _positions pushback (getPosATL _x);
                            _ranks pushback (rank _x);
                            _damages pushback (getDammage _x);

                            // set profile id on the unit
                            _unit setVariable ["profileID", _profileID];
                            _unit setVariable ["profileIndex", _unitCount];

                            // killed event handler
                            if!(isPlayer _unit) then {
                                _eventID = _unit addMPEventHandler["MPKilled", ALIVE_fnc_profileKilledEventHandler];
                            };

                            _unitCount = _unitCount + 1;

                        } foreach (_units);

                        _position = getPosATL _leader;
                        _side = str(side group _leader);

                        _profileEntity = [nil, "create"] call ALIVE_fnc_profileEntity;
                        [_profileEntity, "init"] call ALIVE_fnc_profileEntity;
                        [_profileEntity, "profileID", _profileID] call ALIVE_fnc_profileEntity;
                        [_profileEntity, "unitClasses", _unitClasses] call ALIVE_fnc_profileEntity;
                        [_profileEntity, "position", _position] call ALIVE_fnc_profileEntity;
                        [_profileEntity, "despawnPosition", _position] call ALIVE_fnc_profileEntity;
                        [_profileEntity, "positions", _positions] call ALIVE_fnc_profileEntity;
                        [_profileEntity, "damages", _damages] call ALIVE_fnc_profileEntity;
                        [_profileEntity, "ranks", _ranks] call ALIVE_fnc_profileEntity;
                        [_profileEntity, "side", _side] call ALIVE_fnc_profileEntity;
                        [_profileEntity, "faction", faction _leader] call ALIVE_fnc_profileEntity;
                        [_profileEntity, "isPlayer", true] call ALIVE_fnc_profileEntity;
                        [_profileEntity, "leader", _leader] call ALIVE_fnc_hashSet;
                        [_profileEntity, "group", _group] call ALIVE_fnc_hashSet;
                        [_profileEntity, "units", _units] call ALIVE_fnc_hashSet;
                        [_profileEntity, "active", true] call ALIVE_fnc_hashSet;
                        [_profileEntity, "isSPE", false] call ALIVE_fnc_profileEntity;
                        [_profileEntity, "aiBehaviour", "SAFE"] call ALIVE_fnc_profileEntity;

                        [ALIVE_profileHandler, "registerProfile", _profileEntity] call ALIVE_fnc_profileHandler;

                        _entityCount = _entityCount + 1;

                        [_profileIndex, getPlayerUID _x, _profileEntity] call ALIVE_fnc_hashSet;

                    };

                } forEach _players;

                // DEBUG -------------------------------------------------------------------------------------
                if(_debug) then {
                    _players = [ALIVE_profileHandler, "getPlayerEntities"] call ALIVE_fnc_profileHandler;
                    _players call ALIVE_fnc_inspectHash;
                    ["Player profiler - Create profiles from players complete - total player profiles: [%1]",_entityCount] call ALiVE_fnc_dump;
                };
                // DEBUG -------------------------------------------------------------------------------------
            //};

        };
        case "CONNECT":{

            // a player has connected to the server

            _group = group _player;
            _leader = leader _group;
            _units = units _group;
            _existingPlayers = [];

            if(_player == _leader) then {
                //["Player profiler - Connected player is the group leader: %1",_player] call ALiVE_fnc_dump;
            };

            {
                _unit = _x;
                if(isPlayer _unit) then {
                    _uuid = getPlayerUID _unit;
                    if(_uuid != _uid) then {
                        _existingPlayers pushback _uuid;
                        //["Player profiler - found another player in this group: %1",_unit] call ALiVE_fnc_dump;
                    }else{
                        //["Player profiler - found connecting player in this group: %1",_unit] call ALiVE_fnc_dump;
                    };
                };
            } forEach _units;

            // there are existing players in this group check if they are profiled
            if(count _existingPlayers > 0) then {
                _uuid = _existingPlayers select 0;
                //["Player profiler - checking other players for profile: %1",_uuid] call ALiVE_fnc_dump;
                if(_uuid in (_profileIndex select 1)) then {
                   _existingProfile = [_profileIndex, _uid] call ALIVE_fnc_hashGet;
                };
            };

            if!(isNil "_existingProfile") then {

                //["Player profiler - Existing profile found, add connecting player to profile"] call ALiVE_fnc_dump;

                _profileEntity = _existingProfile;
                _unitClasses = [];
                _positions = [];
                _ranks = [];
                _damages = [];
                _unitCount = 0;
                _profileID = _profileEntity select 2 select 4;

                {
                    _unit = _x;
                    _unitClasses pushback (typeOf _x);
                    _positions pushback (getPosATL _x);
                    _ranks pushback (rank _x);
                    _damages pushback (getDammage _x);

                    // set profile id on the unit
                    _unit setVariable ["profileID", _profileID];
                    _unit setVariable ["profileIndex", _unitCount];

                    _unitCount = _unitCount + 1;

                } foreach (_units);

                _position = getPosATL _leader;
                _side = str(side group _leader);

                [_profileEntity, "unitClasses", _unitClasses] call ALIVE_fnc_profileEntity;
                [_profileEntity, "position", _position] call ALIVE_fnc_profileEntity;
                [_profileEntity, "despawnPosition", _position] call ALIVE_fnc_profileEntity;
                [_profileEntity, "positions", _positions] call ALIVE_fnc_profileEntity;
                [_profileEntity, "damages", _damages] call ALIVE_fnc_profileEntity;
                [_profileEntity, "ranks", _ranks] call ALIVE_fnc_profileEntity;
                [_profileEntity, "side", _side] call ALIVE_fnc_profileEntity;
                [_profileEntity, "faction", faction _leader] call ALIVE_fnc_profileEntity;
                [_profileEntity, "isPlayer", true] call ALIVE_fnc_profileEntity;
                [_profileEntity, "leader", _leader] call ALIVE_fnc_hashSet;
                [_profileEntity, "group", _group] call ALIVE_fnc_hashSet;
                [_profileEntity, "units", _units] call ALIVE_fnc_hashSet;
                [_profileEntity, "active", true] call ALIVE_fnc_hashSet;

                [_profileIndex, _uid, _profileEntity] call ALIVE_fnc_hashSet;

                {
                    [_profileIndex, _x, _profileEntity] call ALIVE_fnc_hashSet;
                } forEach _existingPlayers;

                // DEBUG -------------------------------------------------------------------------------------
                if(_debug) then {
                    _players = [ALIVE_profileHandler, "getPlayerEntities"] call ALIVE_fnc_profileHandler;
                    _players call ALIVE_fnc_inspectHash;
                    _index = [ALIVE_profileHandler, "getPlayerIndex"] call ALIVE_fnc_profileHandler;
                    _index call ALIVE_fnc_inspectHash;
                    ["Player profiler - Create connected player profile complete - total player profiles: [%1]",_entityCount] call ALiVE_fnc_dump;
                };
                // DEBUG -------------------------------------------------------------------------------------

            }else{

                //["Player profiler - No existing profile found, create profile for connecting player"] call ALiVE_fnc_dump;

                _unitClasses = [];
                _positions = [];
                _ranks = [];
                _damages = [];
                _unitCount = 0;
                _profileID = format["player_%1",_entityCount];

                {
                    _unit = _x;
                    _unitClasses pushback (typeOf _x);
                    _positions pushback (getPosATL _x);
                    _ranks pushback (rank _x);
                    _damages pushback (getDammage _x);

                    // set profile id on the unit
                    _unit setVariable ["profileID", _profileID];
                    _unit setVariable ["profileIndex", _unitCount];

                    // killed event handler
                    if!(isPlayer _unit) then {
                        _eventID = _unit addMPEventHandler["MPKilled", ALIVE_fnc_profileKilledEventHandler];
                    };

                    _unitCount = _unitCount + 1;

                } foreach (_units);

                _position = getPosATL _leader;
                _side = str(side group _leader);

                _profileEntity = [nil, "create"] call ALIVE_fnc_profileEntity;
                [_profileEntity, "init"] call ALIVE_fnc_profileEntity;
                [_profileEntity, "profileID", _profileID] call ALIVE_fnc_profileEntity;
                [_profileEntity, "unitClasses", _unitClasses] call ALIVE_fnc_profileEntity;
                [_profileEntity, "position", _position] call ALIVE_fnc_profileEntity;
                [_profileEntity, "despawnPosition", _position] call ALIVE_fnc_profileEntity;
                [_profileEntity, "positions", _positions] call ALIVE_fnc_profileEntity;
                [_profileEntity, "damages", _damages] call ALIVE_fnc_profileEntity;
                [_profileEntity, "ranks", _ranks] call ALIVE_fnc_profileEntity;
                [_profileEntity, "side", _side] call ALIVE_fnc_profileEntity;
                [_profileEntity, "faction", faction _leader] call ALIVE_fnc_profileEntity;
                [_profileEntity, "isPlayer", true] call ALIVE_fnc_profileEntity;
                [_profileEntity, "leader", _leader] call ALIVE_fnc_hashSet;
                [_profileEntity, "group", _group] call ALIVE_fnc_hashSet;
                [_profileEntity, "units", _units] call ALIVE_fnc_hashSet;
                [_profileEntity, "active", true] call ALIVE_fnc_hashSet;
                [_profileEntity, "isSPE", false] call ALIVE_fnc_profileEntity;
                [_profileEntity, "aiBehaviour", "SAFE"] call ALIVE_fnc_profileEntity;

                [ALIVE_profileHandler, "registerProfile", _profileEntity] call ALIVE_fnc_profileHandler;

                _entityCount = _entityCount + 1;

                [_profileIndex, _uid, _profileEntity] call ALIVE_fnc_hashSet;

                {
                    [_profileIndex, _x, _profileEntity] call ALIVE_fnc_hashSet;
                } forEach _existingPlayers;

                // DEBUG -------------------------------------------------------------------------------------
                if(_debug) then {
                    _players = [ALIVE_profileHandler, "getPlayerEntities"] call ALIVE_fnc_profileHandler;
                    _players call ALIVE_fnc_inspectHash;
                    _index = [ALIVE_profileHandler, "getPlayerIndex"] call ALIVE_fnc_profileHandler;
                    _index call ALIVE_fnc_inspectHash;
                    ["Player profiler - Create connected player profile complete - total player profiles: [%1]",_entityCount] call ALiVE_fnc_dump;
                };
                // DEBUG -------------------------------------------------------------------------------------

            };

        };
        case "DISCONNECT":{
            //Identify disconnected players and remove the disconnected ones
            _players = +allPlayers;
            _playerIndexes = +(_profileIndex select 1);

            {_uid = _x; if (({(getPlayerUID _x) == _uid} count _players == 0)) then {["DISCONNECT",_uid] call ALIVE_fnc_createProfilesFromPlayers}} foreach _playerIndexes;
        };
        case "KILLED":{

        };
        case "RESPAWN":{

             // a player has respawned

            _group = group _player;
            _leader = leader _group;
            _units = units _group;
            _existingPlayers = [];

            if(_player == _leader) then {
                //["Player profiler - Respawned player is the group leader: %1",_player] call ALiVE_fnc_dump;
            };

            {
                _unit = _x;
                if(isPlayer _unit) then {
                    _uuid = getPlayerUID _unit;
                    if(_uuid != _uid) then {
                        _existingPlayers pushback _uuid;
                        //["Player profiler - found another player in this group: %1",_unit] call ALiVE_fnc_dump;
                    }else{
                        //["Player profiler - found respawned player in this group: %1",_unit] call ALiVE_fnc_dump;
                    };
                };
            } forEach _units;

            // there are existing players in this group check if they are profiled
            if(count _existingPlayers > 0) then {
                _uuid = _existingPlayers select 0;
                //["Player profiler - checking other players for profile: %1",_uuid] call ALiVE_fnc_dump;
                if(_uuid in (_profileIndex select 1)) then {
                   _existingProfile = [_profileIndex, _uid] call ALIVE_fnc_hashGet;
                };
            };

            if!(isNil "_existingProfile") then {

                //["Player profiler - Existing profile found, add respawned player to profile"] call ALiVE_fnc_dump;

                _profileEntity = _existingProfile;
                _unitClasses = [];
                _positions = [];
                _ranks = [];
                _damages = [];
                _unitCount = 0;
                _profileID = _profileEntity select 2 select 4;

                {
                    _unit = _x;
                    _unitClasses pushback (typeOf _x);
                    _positions pushback (getPosATL _x);
                    _ranks pushback (rank _x);
                    _damages pushback (getDammage _x);

                    // set profile id on the unit
                    _unit setVariable ["profileID", _profileID];
                    _unit setVariable ["profileIndex", _unitCount];

                    _unitCount = _unitCount + 1;

                } foreach (_units);

                _position = getPosATL _leader;
                _side = str(side group _leader);

                [_profileEntity, "unitClasses", _unitClasses] call ALIVE_fnc_profileEntity;
                [_profileEntity, "position", _position] call ALIVE_fnc_profileEntity;
                [_profileEntity, "despawnPosition", _position] call ALIVE_fnc_profileEntity;
                [_profileEntity, "positions", _positions] call ALIVE_fnc_profileEntity;
                [_profileEntity, "damages", _damages] call ALIVE_fnc_profileEntity;
                [_profileEntity, "ranks", _ranks] call ALIVE_fnc_profileEntity;
                [_profileEntity, "side", _side] call ALIVE_fnc_profileEntity;
                [_profileEntity, "faction", faction _leader] call ALIVE_fnc_profileEntity;
                [_profileEntity, "isPlayer", true] call ALIVE_fnc_profileEntity;
                [_profileEntity, "leader", _leader] call ALIVE_fnc_hashSet;
                [_profileEntity, "group", _group] call ALIVE_fnc_hashSet;
                [_profileEntity, "units", _units] call ALIVE_fnc_hashSet;
                [_profileEntity, "active", true] call ALIVE_fnc_hashSet;

                [_profileIndex, _uid, _profileEntity] call ALIVE_fnc_hashSet;

                {
                    [_profileIndex, _x, _profileEntity] call ALIVE_fnc_hashSet;
                } forEach _existingPlayers;

                // DEBUG -------------------------------------------------------------------------------------
                if(_debug) then {
                    _players = [ALIVE_profileHandler, "getPlayerEntities"] call ALIVE_fnc_profileHandler;
                    _players call ALIVE_fnc_inspectHash;
                    _index = [ALIVE_profileHandler, "getPlayerIndex"] call ALIVE_fnc_profileHandler;
                    _index call ALIVE_fnc_inspectHash;
                    ["Player profiler - Create respawned player profile complete - total player profiles: [%1]",_entityCount] call ALiVE_fnc_dump;
                };
                // DEBUG -------------------------------------------------------------------------------------

            }else{

                //["Player profiler - No existing profile found, create profile for respawned player"] call ALiVE_fnc_dump;

                _unitClasses = [];
                _positions = [];
                _ranks = [];
                _damages = [];
                _unitCount = 0;
                _profileID = format["player_%1",_entityCount];

                {
                    _unit = _x;
                    _unitClasses pushback (typeOf _x);
                    _positions pushback (getPosATL _x);
                    _ranks pushback (rank _x);
                    _damages pushback (getDammage _x);

                    // set profile id on the unit
                    _unit setVariable ["profileID", _profileID];
                    _unit setVariable ["profileIndex", _unitCount];

                    // killed event handler
                    if!(isPlayer _unit) then {
                        _eventID = _unit addMPEventHandler["MPKilled", ALIVE_fnc_profileKilledEventHandler];
                    };

                    _unitCount = _unitCount + 1;

                } foreach (_units);

                _position = getPosATL _leader;
                _side = str(side group _leader);

                _profileEntity = [nil, "create"] call ALIVE_fnc_profileEntity;
                [_profileEntity, "init"] call ALIVE_fnc_profileEntity;
                [_profileEntity, "profileID", _profileID] call ALIVE_fnc_profileEntity;
                [_profileEntity, "unitClasses", _unitClasses] call ALIVE_fnc_profileEntity;
                [_profileEntity, "position", _position] call ALIVE_fnc_profileEntity;
                [_profileEntity, "despawnPosition", _position] call ALIVE_fnc_profileEntity;
                [_profileEntity, "positions", _positions] call ALIVE_fnc_profileEntity;
                [_profileEntity, "damages", _damages] call ALIVE_fnc_profileEntity;
                [_profileEntity, "ranks", _ranks] call ALIVE_fnc_profileEntity;
                [_profileEntity, "side", _side] call ALIVE_fnc_profileEntity;
                [_profileEntity, "faction", faction _leader] call ALIVE_fnc_profileEntity;
                [_profileEntity, "isPlayer", true] call ALIVE_fnc_profileEntity;
                [_profileEntity, "leader", _leader] call ALIVE_fnc_hashSet;
                [_profileEntity, "group", _group] call ALIVE_fnc_hashSet;
                [_profileEntity, "units", _units] call ALIVE_fnc_hashSet;
                [_profileEntity, "active", true] call ALIVE_fnc_hashSet;
                [_profileEntity, "isSPE", false] call ALIVE_fnc_profileEntity;
                [_profileEntity, "aiBehaviour", "SAFE"] call ALIVE_fnc_profileEntity;

                [ALIVE_profileHandler, "registerProfile", _profileEntity] call ALIVE_fnc_profileHandler;

                _entityCount = _entityCount + 1;

                [_profileIndex, _uid, _profileEntity] call ALIVE_fnc_hashSet;

                {
                    [_profileIndex, _x, _profileEntity] call ALIVE_fnc_hashSet;
                } forEach _existingPlayers;

                // DEBUG -------------------------------------------------------------------------------------
                if(_debug) then {
                    _players = [ALIVE_profileHandler, "getPlayerEntities"] call ALIVE_fnc_profileHandler;
                    _players call ALIVE_fnc_inspectHash;
                    _index = [ALIVE_profileHandler, "getPlayerIndex"] call ALIVE_fnc_profileHandler;
                    _index call ALIVE_fnc_inspectHash;
                    ["Player profiler - Create respawned player profile complete - total player profiles: [%1]",_entityCount] call ALiVE_fnc_dump;
                };
                // DEBUG -------------------------------------------------------------------------------------

            };

        };
    };
};