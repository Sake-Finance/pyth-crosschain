#!/bin/bash

# Deploys Wormhole and Pyth contracts.
#
# Variables:
# PYTH_DEPLOY_MODE - "katana" or "sepolia" (default: "katana")
# PYTH_WORMHOLE_ADDRESS - if set, the script will use it instead of deploying a new Wormhole contract.
# When using sepolia, set STARKNET_ACCOUNT and STARKNET_KEYSTORE as well.

set -o errexit
set -o nounset
set -o pipefail
set -x

if [ -z ${PYTH_DEPLOY_MODE+x} ]; then
    PYTH_DEPLOY_MODE=katana
fi

if [ "${PYTH_DEPLOY_MODE}" == "katana" ]; then
    export STARKNET_ACCOUNT=katana-0
    export STARKNET_RPC=http://0.0.0.0:5050

    chain_id=50075 # starknet_sepolia

    # predeployed fee token contract in katana
    fee_token_address1=0x49d36570d4e46f48e99674bd3fcc84644ddd6b96f7c741b1562b82f9e004dc7

    # there is no second fee token pre-deployed in katana
    fee_token_address2=0x49d36570d4e46f48e99674bd3fcc84644ddd6b96f7c741b1562b82f9e004dc7
elif [ "${PYTH_DEPLOY_MODE}" == "sepolia" ]; then
    export STARKNET_RPC=https://starknet-sepolia.public.blastapi.io/rpc/v0_6

    chain_id=50075 # starknet_sepolia

    # STRK
    fee_token_address1=0x04718f5a0fc34cc1af16a1cdee98ffb20c31f5cd61d6ab07201858f4287c938d

    # ETH
    fee_token_address2=0x049d36570d4e46f48e99674bd3fcc84644ddd6b96f7c741b1562b82f9e004dc7
else
    >&2 echo "Unsupported PYTH_DEPLOY_MODE"
    exit 1
fi

starkli --version 1>&2
scarb --version 1>&2

cd "$(dirname "$0")/.."
scarb build 1>&2

if [ -z ${PYTH_WORMHOLE_ADDRESS+x} ]; then
    wormhole_hash=$(starkli declare --watch target/dev/pyth_wormhole.contract_class.json)

    # deploying wormhole with mainnet guardians

    # guardian set #4
    PYTH_WORMHOLE_ADDRESS=$(starkli deploy --not-unique --salt 0 --watch "${wormhole_hash}" \
        4 `# guardian_set_index` \
        19 `# num_guardians` \
        0x5893B5A76c3f739645648885bDCcC06cd70a3Cd3 \
        0xfF6CB952589BDE862c25Ef4392132fb9D4A42157 \
        0x114De8460193bdf3A2fCf81f86a09765F4762fD1 \
        0x107A0086b32d7A0977926A205131d8731D39cbEB \
        0x8C82B2fd82FaeD2711d59AF0F2499D16e726f6b2 \
        0x11b39756C042441BE6D8650b69b54EbE715E2343 \
        0x54Ce5B4D348fb74B958e8966e2ec3dBd4958a7cd \
        0x15e7cAF07C4e3DC8e7C469f92C8Cd88FB8005a20 \
        0x74a3bf913953D695260D88BC1aA25A4eeE363ef0 \
        0x000aC0076727b35FBea2dAc28fEE5cCB0fEA768e \
        0xAF45Ced136b9D9e24903464AE889F5C8a723FC14 \
        0xf93124b7c738843CBB89E864c862c38cddCccF95 \
        0xD2CC37A4dc036a8D232b48f62cDD4731412f4890 \
        0xDA798F6896A3331F64b48c12D1D57Fd9cbe70811 \
        0x71AA1BE1D36CaFE3867910F99C09e347899C19C3 \
        0x8192b6E7387CCd768277c17DAb1b7a5027c0b3Cf \
        0x178e21ad2E77AE06711549CFBB1f9c7a9d8096e8 \
        0x5E1487F35515d02A92753504a8D75471b9f49EdB \
        0x6FbEBc898F403E4773E95feB15E80C9A99c8348d \
        "${chain_id}" \
        1 `# governance_chain_id` \
        4 0 `# governance_contract` \
    )

    starkli call "${PYTH_WORMHOLE_ADDRESS}" parse_and_verify_vm \
        22 31 1766847066444781320994483841501749070683184988175346608350833289606460334 212947826323005836459324855622644222616018636992885372105331942586552907468 81660979013353137202642548915832448550451466019996482702323407067724296209 95741624021272728945013270250501993581942556170497732530874878801908144306 165662966900701670449626245581208493004355854955829824194179550634929852833 231912243281085290502810326487185927508155143635177563530631143752065571856 133730969669302854135794272412794164777529338092917842377346428324893829718 97343519857054363566972377057665192056385575884831516477409350758778510013 342746596549774708451947636608846531729658415956055005599080197161394229544 204948333737363743462797621387740902958435788255332697090876514925204619872 125787105691919345394003488771492742490859967707652521322286557930363979017 289200441361010062493817560570776272352820259703146050518813030756504119411 36195295116764854597152684464284437789913478631575450098838448744525463562 130697462617163042959679149176086940549838452585515384044528481294282239773 139674875825513167776845831735936913825147169161587975770748518358126310163 286436305036613647658881186849841354733955967089763556118750317745412087118 5671512721815753211739698846518575453028006970790831305727447899144867646 180304609612262763148200461959875457419015520474026908793738699141169185653 136946758109572962207110548190873778291130450786827595307800254515421619327 17170199244368630212159858748270977608822555594170776804998295695629059235 114140636989602096102794655124749460421508327132088332268734394379961251785 64189131401465205213890974671328939393264177584900517481608375067694905706 28957877657506210079383392143467334592067254866216421163714019229559325481 380789826843014410401773923893528872620094041727761136528833781507143759200 344750914201194299660412358835877469155882340746976208490274423530736037757 368626793571455386480158022104523417706403593747958116469345778842065816527 44398516609262992569922245814359474479109794484528484046528251267154070475 130858275066136325098757860094387148405443006714509562306749555136599024623 43192785595291340058788190601908070333310658291317702311902081 52685537088250779930155363782858917659425217657512936523711408953498337280 14615187937441566980859118820051424312305759711346586 \
        1>&2
fi
echo "PYTH_WORMHOLE_ADDRESS=${PYTH_WORMHOLE_ADDRESS}"

pyth_hash=$(starkli declare --watch target/dev/pyth_pyth.contract_class.json)

emitter_chain_id1=26
emitter_address1=0xf8cd23c2ab91237730770bbea08d61005cdda0984348f3f6eecb559638c0bba0

emitter_chain_id2=26
emitter_address2=0xe101faedac5851e32b9b23b5f9411a8c2bac4aae3ed4dd7b811dd1a72ea4aa71

governance_emitter_chain_id=1
governance_emitter_address=0x5635979a221c34931e32620b9293a463065555ea71fe97cd6237ade875b12e9e

pyth_address=$(starkli deploy --not-unique --salt 0 --watch "${pyth_hash}" \
    "${PYTH_WORMHOLE_ADDRESS}" \
    "${fee_token_address1}" \
    1 0 `# fee_amount1` \
    "${fee_token_address2}" \
    1 0 `# fee_amount2` \
    2 `# num_data_sources` \
    "${emitter_chain_id1}" "0x${emitter_address1:34:32}" "0x${emitter_address1:2:32}" \
    "${emitter_chain_id2}" "0x${emitter_address2:34:32}" "0x${emitter_address2:2:32}" \
    "${governance_emitter_chain_id}" \
    "0x${governance_emitter_address:34:32}" "0x${governance_emitter_address:2:32}" \
    0 `# governance_initial_sequence` \
)

starkli invoke --watch "${fee_token_address1}" approve "${pyth_address}" 1000 0

starkli invoke --watch "${pyth_address}" update_price_feeds \
    11 41 141887862745809943100717722154781668656425228150258363002663887732857548075 399793171101922163607717906910020156439802651815166374105600343045575931912 205983572864866548810075966151139050810706099666354694408986588005072300221 151451952208610765038741735376830560508647207417250420083288609153397964481 86500771940909656434129966404881206990783089169853273096126376095161148476 226128071698991949569342896653857259217290864736270016974365368327197190188 377698250859392108521341636250067678937984182266455992791761951028534274645 359481881021010868573625646624159016709204941239347558851817240293252854322 269752247307988210724584131415546296182395279893478036136383326770680756016 1795390197095010264738527441013169771569683827600670029637766897428840143 234116006474879126519208934707397575502368608154160721412947025189419787194 189800847222104556167598630039931285094024694085247523307780296439180585091 286206863474379560841614954761399331434812535348350225390274576176798886031 380778504466325787198909189418135115031120011427014465236265515817642556890 128785010970678423864351132498736713626005612397319240493515416417380099413 395419216432871057204438489759682910781574046646010114747283889104834443397 184981610545658962928833309057692452941395349433458372962283948260273947156 110573687320157468197346423602708230855113764048934963897254568602798981891 359831064918860887692030922920274851680298668214543004760245859301314852951 430048018037020109398934292236837834709370591653776097569938580165539734124 265079002668517523371293797450754079826401787503533883360533359118093613709 118956066417175616647948432812222980193178970842860785889932661265944570805 289275771653255859826082430219295399339085718287922176066620100061685069367 236281080443323007784750945204995275799519083197981738780888611083509567478 251042542087561162756580709366349731114715604419679060279244203132266921212 98235342442817522140724982668491795525073680697047819016960109902179866805 88342865348230190810084665689239940103607621061956069700600977485132311440 362045407519743532711403801060857872682086780812134177115599591240431143367 16066483776176414842828409371714210177224680637354816226962534075790344474 247660009137502548346315865368477795392972486141407802997108167405894850048 3530678887550352072827758533436734366288448089041832078266099519 272101358674132653417860014541384836605087997364704101839695292681479883518 394112423559676785086059691419737479771752814065338155011845462169193807974 151755140354137577506498286435010205890750984061355535849635897370673003944 210196797635098012510106281616028853575843684847951745405842531072933610917 65848881303037889845233189630325925691014776183743685310081069912626992101 110542381473451658848567609117180625628841970992142907142739541724557861958 157546342890129829983246193527213822449181723932011157069167729323808635205 165998047372192053828934221954381957675361960853286466716634704795532379661 28583007876111384456149499846085318299326698960792831530075402396150538907 126290914008245563820443505

>&2 echo Pyth contract has been successfully deployed at "${pyth_address}"

echo "PYTH_CONTRACT_ADDRESS=${pyth_address}"
