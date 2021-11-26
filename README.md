# Disruptive Insurance

Disruptive Insurance is an exotic insurance service that allows users to buy insurance against volcano eruptions.\
No other insurance business on Earth offers volcano eruption insurance.

Video demo: [https://www.youtube.com/watch?v=SHUC-wjAipU]:
[![Watch the video]("https://github.com/MarcusWentz/InsureDisruption/blob/main/Images/structure.png")](https://www.youtube.com/watch?v=SHUC-wjAipU)

# Buyer
  Buy policy:\
    1.Oracle: Get present time\
    2.Record address, time, input coordinates and locked Owner ETH for policy.\
  Claim Reward from qualified policy:\
    1. Oracle: Get filtered volcano eruption data (time, coordinates)\
    2. Check if policy is older than eruption date and the coordinates are within + or - 1 coordinate point.\
    3. Policy holder claims 1 ETH if Step 2 checks are true then deletes policy data.
  
# Owner:
 Attract Buyers:\
  1.Add funds to make policies available with OwnerSendOneEthToContractFromInsuranceBusiness.\
 Claim ETH\
  Get paid directly after a policy is bought.\
   Expired Claim:\
    1.Oracle: Get present time\
    2.Check if policy connected to a mapped address is over 1 year old.\
    3.Liquidate ETH from policy and delete policy data.\
   Claim ETH not tied to policy\
    1.Check if OpenETHtoInsure is greater than 0.\
    2.Claim one ETH from contract.\
   Self Destruct \
    1.If the sum of AccountsInsured and OpenETHtoInsure is greater than smart contract ETH balance, then a self destruct attack occurred and you can claim that ETH.
