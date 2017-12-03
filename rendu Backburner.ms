



/*
---- LE RENDER STAMP DE CORONA -----------------
m_renderStamp = "camera : %v |  image : %n | Tps de rendu: %pt | Passes: %pp "
m_renderstamp_use
renderers.current.renderStamp
renderers.current.renderstamp_use



#######################################################################################################################
	Christophe Pages (http://www.c-pages.fr) 	
##########################################################################################################################
	
Envoyer des rendu au backburner
	
##########################################################################################################################
	changelog:
	*v0.1 - [19/10/2016] -----------------------------------------------------------------------------
########################################################################################################################*/

-- (

	
include "$userScripts\cp - GLOBAL\UI.ms"

------------------------------------------------------------------------------
----------	dragger une fenetre 					--------------------------
------------------------------------------------------------------------------
struct str_drag (
	
	m_prt, 
	
	posOrigineSouris 		= [0,0],
	posOrigineFenetre 	= [0,0],
	enCours 				= false,
	
	fn demarrer 	=(
		enCours 				= true
		posOrigineSouris		= mouse.screenpos 
		posOrigineFenetre 	= GetDialogPos 	m_prt
	),
	fn arreter  	=(
		enCours 				= false
	),
	fn suivreSouris 	 		= (
		if enCours  do (			
			local ecart = ( mouse.screenpos  - posOrigineSouris )
			SetDialogPos  m_prt	( posOrigineFenetre + ecart )
		)
	)
	
) -- fin struct drag --

------------------------------------------------------------------------------
----------	Fenetre								 -------------------------
------------------------------------------------------------------------------
rollout roll_backburner "backburner" width:136 height:127
(
	------------  Membres	----------------------------------------------------------------------------------
	---- Pointeurs ----
	local m_prt				---- pointeur vers la structure de controle ----
	
	---- Structures ----
	local m_drag			---- la structure gerant le drag de la fenetre ----
	
	
	--- liste des btns pour toggle ----
	local m_btns_MPX
	
	local m_btns_FR
	local m_Back_rendreImage = false
	local m_titre_back
	local m_titre_suffix
	
	--- pour savoir si action utilisateur ou ecouteurs ---
	local m_actionEnCours = false
	
	------------  UI	----------------------------------------------------------------------------------		
		---- le bouton pour fermer la fenetre ----
	ImgTag 'ui_btnFermer' "X" pos:[116,0] width:20 height:20 toolTip:"Fermer" style:#bmp_center align:#left
	
	--- renduBackburner
	ImgTag 'ui_Back_titre' "" pos:[8,4] width:122 height:15 align:#left	
	
	button 'btn_back_image' "Image" pos:[8,19] width:60 height:20 align:#left
	button 'btn_back_film' "Film" pos:[69,19] width:60 height:20 align:#left
	
	checkbox 'btn_critique' "Critique" pos:[8,39] width:120 height:20 align:#left
	dropdownList 'ddl_servers' "" pos:[9,58] width:98 height:21 items:#("All servers") align:#left
	
	button 'btn_actualiserServers' "Maj" pos:[108,58] width:20 height:20 toolTip:"Actualiser la liste des servers" align:#left
	
	ImgTag 'ui_Back_suffixe' "" pos:[8,86] width:122 height:15 align:#left
	editText 'btn_edt_suffixe' "" pos:[8,103] width:119 height:17 align:#left
	
	
	------------  Fonctions	----------------------------------------------------------------------------------
	---- Gere l'état du bouton  -----
	fn etatBtnFermer		_etat =(
		case _etat of (
			#Repos : 	ui_btnFermer.bitmap = m_prt.m_icos_fermer[1]	
			#Survol : 	ui_btnFermer.bitmap = m_prt.m_icos_fermer[2]	
			#Press : 	ui_btnFermer.bitmap = m_prt.m_icos_fermer[3]	
		)
	)
	
	fn actualiserServers =(
		
		-- connection au manager ----
		m_manager = netrender.getmanager() 		--get a NetManager instance
		m_manager.connect #automatic "dogen"	--start this session
		srv_list = m_manager.getservers()	
		
		---- la liste a mettre dans le drpodown
		liste_items = #()
		append liste_items "All servers"
		for server in srv_list do (
			append liste_items server.name
		)
		ddl_servers.items = liste_items
		
		--- selection ---
		if m_prt.m_serverID <= ddl_servers.items.count do 
			ddl_servers.selection = m_prt.m_serverID
		
		-- Déconnection du manager ----
		m_manager.disconnect ()
	)
	
	
	
	
	fn actualiser = (
		
	)
	
	---- Initialisation de la fenetre  -----
	fn initialiser = (
		
		m_drag 		= str_drag 	m_prt:roll_backburner		
		
		
		m_titre_back 		= str_label 	m_ui:ui_Back_titre			m_texte:"Backburner"
		m_titre_back.setCouleur (color 255	255	255)
		m_titre_back.setCouleurFond 	m_prt.col_fenetreFond
		
		
	
		
		m_titre_suffix 		= str_label 	m_ui:ui_Back_suffixe			m_texte:"Suffixe du Job"
		m_titre_suffix.setCouleur (color 255	255	255)
		m_titre_suffix.setCouleurFond 	m_prt.col_fenetreFond
		
		actualiserServers ()
		
		btn_edt_suffixe.text =		m_prt.m_suffixe
		
		-- le bouton fermer --
		ui_btnFermer.bitmap = m_prt.m_icos_fermer[1]	
		
		actualiser()

	)
	
	
	------------  Evenements	----------------------------------------------------------------------------------
	on roll_backburner lbuttondown _pos 	do
		m_drag.demarrer ()
	on roll_backburner lbuttonup _pos 	do
		m_drag.arreter ()
	on roll_backburner mouseMove _pos 	do
		m_drag.suivreSouris ()
	on ui_btnFermer mouseover do
		etatBtnFermer #Survol
	on ui_btnFermer mouseout do
		etatBtnFermer #Repos
	on ui_btnFermer mouseDown do
		etatBtnFermer #Press
	on ui_btnFermer mouseUp do
		etatBtnFermer #Repos	
	on ui_btnFermer click do
		m_prt.fermer ()
	
	
	
	
	on btn_back_image pressed do
		m_prt.envoyer_renduBackburner  true
	
	on btn_back_film pressed do
		m_prt.envoyer_renduBackburner  false
	
	on btn_critique changed state do (
		m_prt.b_critique = state
	)
	on ddl_servers selected sel do
	(
		m_prt.m_serverID = sel
-- 		format " on ddl_servers selected sel do : %\n" sel
	)
	on btn_actualiserServers pressed  do
	(
		actualiserServers ()
	)
	
	
	on btn_edt_suffixe changed txt  do (
		m_prt.m_suffixe = txt
	)
)


------------------------------------------------------------------------------
----------	Structure								 -------------------------
------------------------------------------------------------------------------
struct str_backburner (
	
		------------  Membres	----------------------------------------------------------------------------------
	public
		---- pointeurs ----
		m_dialog			= roll_backburner ,		---- le rollout ----
		m_dialogPos 	= [1600,100],
		
		col_fenetreFond			= color 68  68 68, 	----  ----
		col_fenetreTxt				= color 230  230 230, 	----  ----
	
		--- images bouton fermer ---
		ico_btnFermer_R	=	"$userScripts\cp - GLOBAL\ico\ico_fermer_R.jpg",
		ico_btnFermer_S	=	"$userScripts\cp - GLOBAL\ico\ico_fermer_S.jpg",
		ico_btnFermer_P	=	"$userScripts\cp - GLOBAL\ico\ico_fermer_P.jpg",
		
		m_icos_fermer = #( 					---- les images pour les icones du bouton de fermeture ----
									openBitMap ico_btnFermer_R ,		-- Repos ----
									openBitMap ico_btnFermer_S ,		-- Survol ----
									openBitMap ico_btnFermer_P 		-- Pressé ----
								),
		
	
		--- Backburner ----
		b_critique = false,
		m_jobsExistant,
		m_manager,
		m_serverID = 1,
		
		m_suffixe ="",
		
		
		------------  Fonctions	----------------------------------------------------------------------------------
	public
		--- backburner ------------------------
								
		fn incrementerNom_job 	_nom =(
				
				nouveauNom = ""
				nouvelIndex = 1
				
				termineParUnNombre = substring  _nom  (_nom.count  - 3 ) _nom.count
				if ( termineParUnNombre as integer ) != undefined then(
					---termine par un nombre ----
					nouveauNom = substring  _nom  1 (_nom.count  - 3 ) 
					nouvelIndex = termineParUnNombre as integer + 1
					
					for i = 1 to 3 - (nouvelIndex as string).count do 
						nouveauNom = nouveauNom + "0"
					
					nouveauNom = nouveauNom + nouvelIndex as string
					
				) else (
					---termine pas par un nombre ----
					nouveauNom = _nom + " 001"
				)
				
				nouveauNom
				
		),
		--- on verifie si deja present dans liste du manager -----
		-- renvois undefined si pas present, sinon renvois le job existant ---
		fn getJobByName 		_jobName = (
			b_jobPresent = false
			jobDejaPresent = undefined
			for jobExistant in m_jobsExistant do (		
				if jobExistant.name == _jobName
					do (
						jobDejaPresent = jobExistant
					)
			)
			jobDejaPresent
		),

		fn jobDejaPresent _jobName = (
			getJobByName 	_jobName !=  undefined
		),

		fn fichierDejaPresentDansManager _nom =(
		
			b_fichierPresent = false
			for jobExistant in m_jobsExistant do 
				if jobExistant.frameOutputName == _nom do 
					b_fichierPresent = true
			format "###	le fichier : %,  dans le manager : %\n" _nom 		b_fichierPresent
			b_fichierPresent
		),

		fn trouverNom_job _nom =(
			b_trouve=false
			nouveauNom = _nom
			
			while not b_trouve do (
				
				nouveauNom = incrementerNom_job nouveauNom
				
				if not jobDejaPresent nouveauNom do b_trouve = true
			)
			nouveauNom
		),
		
		
		fn soumettreRendu 	_job=(
			if m_serverID <= 1 then (
				_job.submit () --servers:srv_list
			) else (
				srv_list = m_manager.getservers()	
				_job.submit servers:srv_list[m_serverID - 1]
			)
			format "Job \"%\" envoyé au Backburner avec succés.\n"  _job.name
		),
		
		
		
		fn incrementerNom_fichier _nom =(
			
				nouveauNom = ""
				nouvelIndex = 1 
				local extension = getFilenameType _nom
			
-- 				format "-->		extension : %\n" extension
-- 				format "-->		extension.count : %\n" extension.count
				_nom = substring  _nom  1 (_nom.count  - extension.count )
-- 				format "-->		_nom : %\n" _nom
			
				termineParUnNombre = substring  _nom  (_nom.count  - 2 ) _nom.count
			
-- 				format "-->		termineParUnNombre : %\n" termineParUnNombre
			
				if ( termineParUnNombre as integer ) != undefined then(
					---termine par un nombre ----
					nouveauNom = substring  _nom  1 (_nom.count  - 2 ) 
					nouvelIndex = termineParUnNombre as integer + 1
					
					for i = 1 to 2 - (nouvelIndex as string).count do 
						nouveauNom = nouveauNom + "0"
					
					nouveauNom = nouveauNom + nouvelIndex as string
					
				) else (
					---termine pas par un nombre ----
					nouveauNom = _nom + " 01"
				)
				
				nouveauNom = nouveauNom + extension
				
				
		),
		
		
		
		fn trouverNom_fichier _nom =(
			
			format "-->		trouverNom_fichier : %\n" _nom
			
			b_trouve=false
			nouveauNom = _nom
			
			while not b_trouve do (
				
			format "		WHILE\n"
				-- debug----
				if not doesFileExist 	nouveauNom do 
					format "###	le fichier : %, n'existe pas.\n" nouveauNom
-- 					
-- 				if not fichierDejaPresentDansManager 	nouveauNom do 
-- 					format "###	le fichier : %, n'existe pas dans le manager.\n" nouveauNom
				
				-- on verifie si le fichier exist deja sur le DD---et  on vérifie si il exist déja dans les jobs du manager ---
				if not doesFileExist 	nouveauNom and not fichierDejaPresentDansManager 	nouveauNom	
					then b_trouve = true
					else nouveauNom = incrementerNom_fichier 	nouveauNom
				
			)
			nouveauNom
			
			
			
		),
		
		
		
		
		fn envoyer_renduBackburner  _rendreImageSolo  	=(
			
-- 			local rendSaveFileBACK = rendSaveFile
			
			--- on active la sauvegarde  de rendu -- string
			rendSaveFile = true
			
			-- on verifie le nom de l'image ---
			local nomRenduBack = rendOutputFilename
			local nomRendu = rendOutputFilename
			
		/* 	--si existe on ouvre boitre de diaglogue 
			if doesfileExist nomRendu do (
				nomRendu = selectSaveBitMap caption:"Le fichier de rendu existe déja, nouveau nom"\
										filename:rendOutputFilename  
				rendOutputFilename = nomRendu
			) */
			
			--- Connection au Manager
			m_manager = netrender.getmanager() 		--get a NetManager instance
			m_manager.connect #automatic "dogen"	--start this session		 
			
			-- on liste les jobs ----
			m_jobsExistant = m_manager.getjobs ()
		 
			--- nouveau job -----
			job = m_manager.newjob()
			
			--- nom du job -----
			if m_suffixe != "" 		then job.name = job.name + " - " + m_suffixe
				else if _rendreImageSolo 		do job.name = job.name + " - image"
			
			--- nom du fichier rendu ----
			local nomDuFichier = trouverNom_fichier 		job.frameOutputName 
			job.frameOutputName = nomDuFichier
			format "-->		job.frameOutputName : %\n" job.frameOutputName
			
			--- intervalle du job -----
			if _rendreImageSolo 	then (
				job.fromFrame 	= 	job.toFrame 		= currentTime
			)		else (
				job.fromFrame 	= animationRange.start	
				job.toFrame 		=  animationRange.end
			)
			
			--- priorité du job -----
			if b_critique do
				job.priority = 0
			
			---- envois du job qu manager -----------------------------
			b_jobPresent = jobDejaPresent   job.name
			
			--- si pas present on envoie ----
			if not b_jobPresent then (				
				soumettreRendu job
			) else (
				b_remplacer = yesNoCancelBox  "Un job avec le m_managerême nom est présent dans la liste du manager. Voulez vous le remplacer ? (non : envois le job avec un nom incrementé)"
				
				case b_remplacer of (
					#yes:(
						--- on doit prendre le control ----
						if ( m_manager.QueryControl #wait ) do 
							m_manager.getcontrol() 
						m_manager.wantControl=true 
						--- on supprime l'ancien ----
						(getJobByName job.name ).Delete()		
						
						-- on envoie le nouveau ----
					soumettreRendu job
					)	
					#no:	(
						-- on cherche un nom possible
						job.name =trouverNom_job job.name		
						
						-- on envoie le nouveau ----
						soumettreRendu job
					
					)
				)
			)
			---- on ferme la session ----
			m_manager.disconnect ()
 
			
			
		),
		
		
		
		
		
		fn actualiser =(		
			m_dialog.actualiser () 	
		),
		
		
		
		fn setFrameRate 	_fRate =(
			if _fRate != framerate do (
				
				-- on change le frame rate ----
				framerate 					= _fRate
				
				-- on actualise ----
				animationRange = interval 	animationRange.start	animationRange.end
				
			)
			
		),
		
		
		---- fenetre -----
		fn ouvrir =(			
			---- creation de la fenetre ----			
			createDialog m_dialog 	style:				#(#style_resizing) \
											lockHeight:			true	\
											lockWidth:			true	\
											pos:					m_dialogPos
			
			---- initialisation de la fenetre ----
			m_dialog.m_prt	 	= this
			m_dialog.initialiser ()
			
			
		),
		
		fn fermer  silence:false =(		---- silence : fermer sans modifier l'état des preferences ---
			
			m_dialogPos = getDialogPos m_dialog
			
			---- fermer la fenêtre ----
			try destroydialog m_dialog catch ()
			
		)
		
		------------  Evenements	----------------------------------------------------------------------------------
	
)


-- global mgr_backburner 	=	str_backburner 	()
-- mgr_backburner.ouvrir ()





-- )











