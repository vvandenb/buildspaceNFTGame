const main = async () => {
	const gameContractFactory = await hre.ethers.getContractFactory('MyEpicGame');
	const gameContract = await gameContractFactory.deploy(
		["Spyro", "Hunter", "Elora"],
		["https://static.wikia.nocookie.net/spyro/images/4/47/Spyro_PS1_original.jpg/revision/latest/scale-to-width-down/425?cb=20190330094953",
		"https://static.wikia.nocookie.net/spyro/images/a/a7/Hunter_PS1.jpg/revision/latest/scale-to-width-down/403?cb=20180824200042", 
		"https://static.wikia.nocookie.net/spyro/images/a/a6/Elora_PS1.jpg/revision/latest/scale-to-width-down/409?cb=20180824195930"],
		[25, 10, 50],
		[25, 50, 10],
		"Ripto",
		"https://static.wikia.nocookie.net/spyro/images/3/34/Ripto_Ripto%27s_Rage.png/revision/latest/scale-to-width-down/615?cb=20180709173303",
		500,
		4
	);
	await gameContract.deployed();
	console.log("Contract deployed to:", gameContract.address, "\n\n");

	await gameContract.mintCharacterNFT(2);
	await gameContract.mintCharacterNFT(1);
	await gameContract.attackBoss();
	await gameContract.attackBoss();
  };
  
  const runMain = async () => {
	try {
	  await main();
	  process.exit(0);
	} catch (error) {
	  console.log(error);
	  process.exit(1);
	}
  };
  
  runMain();
