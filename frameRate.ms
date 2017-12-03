

/*
#######################################################################################################################
	Christophe Pages (http://www.c-pages.fr) 	
##########################################################################################################################
	Changer le frame rate
	
##########################################################################################################################
	changelog:
	*v0.1 - [27/04/2017 -----------------------------------------------------------------------------
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
	fn suivreSouris 	 	=(
		if enCours  do (			
			local ecart = ( mouse.screenpos  - posOrigineSouris )
			SetDialogPos  m_prt	( posOrigineFenetre + ecart )
		)
	)
	
) -- fin struct drag --

------------------------------------------------------------------------------
----------	Fenetre								 -------------------------
------------------------------------------------------------------------------
rollout roll_frameRate "frameRate" width:137 height:69
(
	------------  Membres	----------------------------------------------------------------------------------
	---- Pointeurs ----
	local m_prt				---- pointeur vers la structure de controle ----
	
	---- Structures ----
	local m_drag			---- la structure gerant le drag de la fenetre ----
	
	--- ctro des imgtags ---
	local m_titre
	local m_log
	
	--- liste des btns pour toggle ----
	local m_btns
	
	--- pour savoir si action utilisateur ou ecouteurs ---
	local m_actionEnCours = false
	
	------------  UI	----------------------------------------------------------------------------------		
	---- le bouton pour fermer la fenetre ---- 

	ImgTag 'ui_btnFermer' "X" pos:[115,0] width:20 height:20 toolTip:"Fermer" style:#bmp_center align:#left
	
	checkbutton 'btn_12' "12" pos:[8,23] width:20 height:20 align:#left
	checkbutton 'btn_24' "24" pos:[28,23] width:20 height:20 align:#left
	checkbutton 'btn_30' "30" pos:[48,23] width:20 height:20 align:#left
	
	
	spinner 'ui_anim_debut' "" pos:[8,46] width:60 height:16 type:#integer scale:1 range:[-10000,10000,0]	tooltip:"Debut de l'animation"
	spinner 'ui_anim_fin' "" pos:[68,47] width:60 height:16 type:#integer scale:1 range:[-10000,10000,0]	tooltip:"Fin de l'animation"
	
	ImgTag 'ui_titre' "" pos:[8,4] width:66 height:18 align:#left
	ImgTag 'ui_log' "" pos:[71,25] width:63 height:18 align:#left

	
	------------  Fonctions	----------------------------------------------------------------------------------
	---- Gere l'état du bouton  -----
	fn etatBtnFermer		_etat =(
		case _etat of (
			#Repos : 	ui_btnFermer.bitmap = m_prt.m_icos_fermer[1]	
			#Survol : 	ui_btnFermer.bitmap = m_prt.m_icos_fermer[2]	
			#Press : 	ui_btnFermer.bitmap = m_prt.m_icos_fermer[3]	
		)
	)
	
	fn toggleBtns  _btn =(
		for btn in m_btns where btn != _btn do	btn.checked = false
		if _btn != undefined do _btn.checked = true
	)
	fn selectBtn 	_frate =(
		
		case _frate of (
			12: 		toggleBtns 	btn_12
			24: 		toggleBtns 	btn_24
			30: 		toggleBtns 	btn_30
			default:	toggleBtns	undefined
		)
		
	)
	
	fn nbrEnString 	_nombre =(
		local result =""
		_nombre = _nombre as string
		
		local characPos =  mod _nombre.count 3
		
		
		local i
		while _nombre.count > 0 do (
			if characPos > 0 do (
				for i = 1 to characPos do result+= _nombre[i]
				result+= " "
				_nombre = substring _nombre 	(characPos+1) 	_nombre.count
			)
			characPos = 3
		)
		result
	)
	
	fn actualiser = (
		
		selectBtn  ( frameRate )
		
		ui_anim_debut.value = animationRange.start
		ui_anim_fin.value 	= animationRange.end
		
		---- log ----
		local txtLog = "im./s. : "
		txtLog += nbrEnString  ( framerate)
		m_log.setTexte txtLog
		
	)
	
	---- Initialisation de la fenetre  -----
	fn initialiser = (
		
		
		m_btns = #( btn_12, btn_24, btn_30 )
		
		
		---- interface ----
		m_drag 		= str_drag 	m_prt:roll_frameRate		
		
		m_titre 		= str_label 	m_ui:ui_titre			m_texte:"Frame rate"
		m_titre.setCouleur (color 255	255	255)
		m_titre.setCouleurFond 	m_prt.col_fenetreFond
		
		m_log 		= str_label 	m_ui:ui_log				m_texte:"..."
		m_log.setPolice (str_policePetite())
		m_log.setCouleur (color 200	200	200)
		m_log.setCouleurFond 	m_prt.col_fenetreFond
		
		
		-- le bouton fermer --
		ui_btnFermer.bitmap = m_prt.m_icos_fermer[1]	
		
		actualiser()

	)
	
	
	
	------------  Evenements	----------------------------------------------------------------------------------
	on roll_frameRate lbuttondown _pos 	do
		m_drag.demarrer ()
	on roll_frameRate lbuttonup _pos 	do
		m_drag.arreter ()
	on roll_frameRate mouseMove _pos 	do
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
	
	on btn_12 	changed state do	undo "Changer frame rate " on  (
		
		m_actionEnCours = true		
		
		toggleBtns	 btn_12
		
		m_prt.setFrameRate 12
		
		actualiser()		
		
		m_actionEnCours = false
			
	)
	
	on btn_24 	changed state do 	undo "Changer frame rate " on (
		m_actionEnCours = true		
		
		toggleBtns	 btn_12
		
		m_prt.setFrameRate 24
		
		actualiser()		
		
		m_actionEnCours = false
	)
	
	on btn_30 	changed state do 	undo "Changer frame rate " on (
		m_actionEnCours = true		
		
		toggleBtns	 btn_30
		
		m_prt.setFrameRate 30
		
		actualiser()		
		
		m_actionEnCours = false
	)
	
	
	on ui_anim_debut changed val do 	undo "Changer debut animation " on (		
		animationRange = interval 	val	animationRange.end
		actualiser ()
	)
	on ui_anim_fin changed val do	undo "Changer fin animation " on (		
		animationRange = interval 	animationRange.start val	
		actualiser ()
	)
)

------------------------------------------------------------------------------
----------	Structure								 -------------------------
------------------------------------------------------------------------------
struct str_frameRate (
	
		------------  Membres	----------------------------------------------------------------------------------
	public
		---- pointeurs ----
		m_dialog			= roll_frameRate ,		---- le rollout ----
		m_dialogPos 	= [1737,100],
		
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
		
		
		
		------------  Fonctions	----------------------------------------------------------------------------------
	public
		

		fn setFrameRate 	_fRate =(
			if _fRate != framerate do (
				
				-- on change le frame rate ----
				framerate 					= _fRate
				
				-- on actualise ----
				animationRange = interval 	animationRange.start	animationRange.end
				
			)
			
		),
		
		
		fn actualiser =(		
			m_dialog.actualiser () 	
		),
		
		---- fenetre -----
		fn ouvrir =(			
			---- creation de la fenetre ----
			createDialog m_dialog 	bgcolor:				col_fenetreFond 	 \
											fgcolor:				col_fenetreTxt 	\
											style:				#(#style_resizing) \
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


-- global mgr_frameRate 	=	str_frameRate 	()
-- mgr_frameRate.ouvrir ()




-- )

