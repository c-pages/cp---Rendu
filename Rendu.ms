/*
---- LE RENDER STAMP DE CORONA -----------------
m_renderStamp = "camera : %v |  image : %n | Tps de rendu: %pt | Passes: %pp "
m_renderstamp_use
renderers.current.renderStamp
renderers.current.renderstamp_use









#######################################################################################################################
	Christophe Pages (http://www.c-pages.fr) 	
##########################################################################################################################
	
	HD et LD
	
##########################################################################################################################
	Permet de passer la taille du rendu en 20 mega pixels (HD ) ou 10 mega pixels (LD)
	
##########################################################################################################################
	changelog:
	*v0.1 - [19/10/2016] -----------------------------------------------------------------------------
########################################################################################################################*/

-- (

	
include "$userScripts\cp - GLOBAL\UI.ms"

------------------------------------------------------------------------------
----------	structure des presets				--------------------------
------------------------------------------------------------------------------
struct str_presetRendu (	
	progressive_passLimit,
	adaptivity_targetError,
	denoise_blendAmount,
	renderStamp,
	renderstamp_use
)



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
rollout roll_rendu "rendu" width:136 height:274
(
	------------  Membres	----------------------------------------------------------------------------------
	---- Pointeurs ----
	local m_prt				---- pointeur vers la structure de controle ----
	
	---- Structures ----
	local m_drag			---- la structure gerant le drag de la fenetre ----
	
	--- ctro des imgtags ---
	local m_titre_MPX
	local m_log_MPX
	
	--- ctro des imgtags ---
	local m_titre_FR
	local m_log_FR
	
	local m_titre_Qualite
	local m_titre_range
	
	--- liste des btns pour toggle ----
	local m_btns_MPX
	
	local m_btns_FR
	local m_btns_Qualite
	
	--- pour savoir si action utilisateur ou ecouteurs ---
	local m_actionEnCours = false
		------------  UI	----------------------------------------------------------------------------------		
	---- le bouton pour fermer la fenetre ----
	ImgTag 'ui_btnFermer' "X" pos:[116,0] width:20 height:20 toolTip:"Fermer" style:#bmp_center align:#left
	
	edittext 'edt_fichierRendu' "" pos:[4,25] width:124 height:16 align:#left
	---- MPX ----
	ImgTag 'ui_MPX_titre' "" pos:[8,4] width:66 height:15 align:#left
	
	checkbutton 'btn_MPX_20' "20" pos:[8,44] width:20 height:20 align:#left
	checkbutton 'btn_MPX_15' "15" pos:[28,44] width:20 height:20 align:#left
	checkbutton 'btn_MPX_10' "10" pos:[48,44] width:20 height:20 align:#left
	checkbutton 'btn_MPX_5' "5" pos:[68,44] width:20 height:20 align:#left
	checkbutton 'btn_MPX_2' "2" pos:[88,44] width:20 height:20 align:#left
	checkbutton 'btn_MPX_1' "1" pos:[108,44] width:20 height:20 align:#left	
	
	
	
	
	
	checkbutton 'btn_MPX_fullHD' "Full HD" pos:[8,63] width:41 height:20 toolTip:"1920 de large" align:#left
	checkbutton 'btn_MPX_HD' "HD" pos:[48,63] width:41 height:20 toolTip:"1280 de large" align:#left
	checkbutton 'btn_MPX_2HD' "1/2 HD" pos:[88,63] width:41 height:20 toolTip:"960 de large" align:#left	
	
	
	
	
	
	ImgTag 'ui_MPX_log' "" pos:[8,98] width:66 height:18 align:#left
	
	---- FRAME RATE ----
	ImgTag 'ui_FR_titre' "" pos:[8,190] width:66 height:15 align:#left	
	
	
	
	
	
	checkbutton 'btn_FR_12' "12" pos:[8,205] width:20 height:20 align:#left
	checkbutton 'btn_FR_24' "24" pos:[28,205] width:20 height:20 align:#left
	checkbutton 'btn_FR_30' "30" pos:[48,205] width:20 height:20 align:#left	
	
	
	
	
	
	spinner 'ui_anim_debut' "" pos:[8,248] width:60 height:16 range:[-10000,10000,0] type:#integer scale:1 toolTip:"Debut de l'animation" align:#left
	spinner 'ui_anim_fin' "" pos:[68,249] width:60 height:16 range:[-10000,10000,0] type:#integer scale:1 toolTip:"Fin de l'animation" align:#left	
	
	
	
	
	
	ImgTag 'ui_FR_log' "" pos:[71,207] width:63 height:18 align:#left

	---- QUALITE -----
	ImgTag 'ui_QUAL_titre' "" pos:[8,126] width:66 height:15 align:#left
	checkbutton 'btn_QUAL_brouillon' "Brouillon" pos:[8,141] width:60 height:20 align:#left
	checkbutton 'btn_QUAL_production' "Production" pos:[69,141] width:60 height:20 align:#left
	checkbutton 'btn_QUAL_final' "Final" pos:[8,161] width:121 height:20 align:#left

	ImgTag 'ui_range_titre' "" pos:[8,230] width:66 height:15 align:#left
	spinner 'spn_ratio' "Ratio" pos:[9,82] width:91 height:16 range:[0.001,1000,1] align:#left  scale:0.01
	
	
	------------  Fonctions	----------------------------------------------------------------------------------

	---- Gere l'état du bouton  -----
	fn etatBtnFermer		_etat =(
		case _etat of (
			#Repos : 	ui_btnFermer.bitmap = m_prt.m_icos_fermer[1]	
			#Survol : 	ui_btnFermer.bitmap = m_prt.m_icos_fermer[2]	
			#Press : 	ui_btnFermer.bitmap = m_prt.m_icos_fermer[3]	
		)
	)
	
	fn toggleBtns_MPX  _btn =(
		for btn in m_btns_MPX where btn != _btn do	btn.checked = false
		_btn.checked = true
	)
		
	fn toggleBtns_FR  _btn =(
		for btn in m_btns_FR where btn != _btn do	btn.checked = false
		if _btn != undefined do _btn.checked = true
	)

	
	fn selectBtn_qualite  =(
		
		
		for btn_id = 1 to m_btns_Qualite.count do (
			
			local btn_checked = false
			local presetsQualite = m_prt.m_presetsQualite
			
			if presetsQualite[ btn_id ].progressive_passLimit 	== renderers.current.progressive_passLimit do 
			if presetsQualite[ btn_id ].adaptivity_targetError 	== renderers.current.adaptivity_targetError do 
			if presetsQualite[ btn_id ].denoise_blendAmount 	== renderers.current.denoise_blendAmount do 
			if presetsQualite[ btn_id ].renderStamp 				== renderers.current.renderStamp do 
			if presetsQualite[ btn_id ].renderstamp_use 			== renderers.current.renderstamp_use then 
				btn_checked = true
			
			m_btns_Qualite[ btn_id ].checked = btn_checked
			
		)
		
		
		
	)
	
	fn selectBtn_MPX 	_ID =(
		
		if classof _ID == Name then (
			
			if _ID == #fullHD then 
				if not m_btns_MPX[7].checked 
					do	toggleBtns_MPX 	m_btns_MPX[7]
			
			else if _ID == #HD then 
				if not m_btns_MPX[8].checked 
					do	toggleBtns_MPX 	m_btns_MPX[8]
				
			else if _ID == #demiHD then 
				if not m_btns_MPX[9].checked 
					do	toggleBtns_MPX 	m_btns_MPX[9]
				
		)	else if _ID >0 do 		
			if not m_btns_MPX[_ID].checked 
				do	toggleBtns_MPX 	m_btns_MPX[_ID]
		
		
		
	)
	
	fn selectBtn_FR 	_frate =(
		
		case _frate of (
			12: 		toggleBtns_FR 	btn_FR_12
			24: 		toggleBtns_FR 	btn_FR_24
			30: 		toggleBtns_FR 	btn_FR_30
			default:	toggleBtns_FR	undefined
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
		if m_prt.m_dialog.open do (
			
			edt_fichierRendu.text = filenameFromPath rendOutputFilename
			
			--- MPX ----
			selectBtn_MPX  ( m_prt.getRenduPixels () )
			
			local txtLog = ""
			txtLog += nbrEnString  ( renderWidth * renderHeight ) + " Mpx."
			txtLog += "§" + "(" + renderWidth as string + " x " + renderHeight as string + " px.)"
			m_log_MPX.setTexte txtLog
			
			spn_ratio.value = getRendImageAspect() 
			
			
			---- FRAME RATE ----
			selectBtn_FR  ( frameRate )
			
			ui_anim_debut.value = animationRange.start
			ui_anim_fin.value 	= animationRange.end
			
			---- Qualite ----
			selectBtn_qualite ()	
			
			
			---- log ----
			local txtLog = "im./s. : "
			txtLog += nbrEnString  ( framerate)
			m_log_FR.setTexte txtLog
		)
	)
	
	---- Initialisation de la fenetre  -----
	fn initialiser = (
		
		m_drag 		= str_drag 	m_prt:roll_rendu		
		
		--- MPX ----
		m_btns_MPX = #( btn_MPX_20, btn_MPX_15, btn_MPX_10, btn_MPX_5, btn_MPX_2, btn_MPX_1 , btn_MPX_fullHD , btn_MPX_HD, btn_MPX_2HD )		
		
		m_titre_MPX 		= str_label 	m_ui:ui_MPX_titre			m_texte:"RENDU"
		m_titre_MPX.setCouleur (color 255	255	255)
		m_titre_MPX.setCouleurFond 	m_prt.col_fenetreFond
		
		m_log_MPX 		= str_label 	m_ui:ui_MPX_log				m_texte:"..."
		m_log_MPX.setPolice (str_policePetite())
		m_log_MPX.setCouleur (color 200	200	200)
		m_log_MPX.setCouleurFond 	m_prt.col_fenetreFond
		
		---- frame rate ----			
		m_btns_FR = #( btn_FR_12, btn_FR_24, btn_FR_30 )
		
		m_titre_FR 		= str_label 	m_ui:ui_FR_titre			m_texte:"Frame rate"
		m_titre_FR.setCouleur (color 255	255	255)
		m_titre_FR.setCouleurFond 	m_prt.col_fenetreFond
		
		m_log_FR 		= str_label 	m_ui:ui_FR_log				m_texte:"..."
		m_log_FR.setPolice (str_policePetite())
		m_log_FR.setCouleur (color 200	200	200)
		m_log_FR.setCouleurFond 	m_prt.col_fenetreFond
		
		----- qualité -----
		m_btns_Qualite = #(btn_QUAL_brouillon, btn_QUAL_production, btn_QUAL_final )
		m_titre_Qualite 		= str_label 	m_ui:ui_QUAL_titre			m_texte:"Qualité"
		m_titre_Qualite.setCouleur (color 255	255	255)
		m_titre_Qualite.setCouleurFond 	m_prt.col_fenetreFond
		
		
		m_titre_range 		= str_label 	m_ui:ui_range_titre			m_texte:"Range"
		m_titre_range.setCouleur (color 255	255	255)
		m_titre_range.setCouleurFond 	m_prt.col_fenetreFond
		
		
			
			-- le bouton fermer --
		ui_btnFermer.bitmap = m_prt.m_icos_fermer[1]	
		
		actualiser()

	)
	
	
	------------  Evenements	----------------------------------------------------------------------------------
	
	---- MPX -----------
	
	
	
	
	
	
	---- Frame rate ------------
	
	
	
	
	
	
	
	
	---- qualite -----
	
	
	on roll_rendu lbuttondown _pos 	do
		m_drag.demarrer ()
	on roll_rendu lbuttonup _pos 	do
		m_drag.arreter ()
	on roll_rendu mouseMove _pos 	do
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
	on edt_fichierRendu entered text do
	(
			local chemin = getFilenamePath		rendOutputFilename
			rendOutputFilename = 	chemin + "\\" + text
		
		)
	on btn_MPX_20 changed state do
	(
			m_actionEnCours = true
			
			toggleBtns_MPX	 btn_MPX_20
			m_prt.setTaille 20
			
			actualiser()
			m_actionEnCours = false
		)
	on btn_MPX_15 changed state  do
	(
			m_actionEnCours = true
			
			toggleBtns_MPX	 btn_MPX_15
			m_prt.setTaille 15
			
			actualiser()
			m_actionEnCours = false
		)
	on btn_MPX_10 changed state  do
	(
			m_actionEnCours = true
			
			toggleBtns_MPX	 btn_MPX_10
			m_prt.setTaille 10
			
			actualiser()
			m_actionEnCours = false
		)
	on btn_MPX_5 changed state  do
	(
			m_actionEnCours = true
			
			toggleBtns_MPX	 btn_MPX_5
			m_prt.setTaille 5
			
			actualiser()
			m_actionEnCours = false
		)
	on btn_MPX_2 changed state  do
	(
			m_actionEnCours = true
			
			toggleBtns_MPX	 btn_MPX_2
			m_prt.setTaille 2
			
			actualiser()
			m_actionEnCours = false
		)
	on btn_MPX_1 changed state  do
	(
			m_actionEnCours = true
			
			toggleBtns_MPX	 btn_MPX_1
			m_prt.setTaille 1
			
			actualiser()
			m_actionEnCours = false
		)
	on btn_MPX_fullHD changed state  do
	(
			m_actionEnCours = true
			
			toggleBtns_MPX	 btn_MPX_fullHD
			m_prt.setTaille 	#fullHD
			
			actualiser()
			m_actionEnCours = false
		)
	on btn_MPX_HD changed state  do
	(
			m_actionEnCours = true
			
			toggleBtns_MPX	 btn_MPX_HD
			m_prt.setTaille 	#HD
			
			actualiser()
			m_actionEnCours = false
		)
	on btn_MPX_2HD changed state  do
	(
			m_actionEnCours = true
			
			toggleBtns_MPX	 btn_MPX_2HD
			m_prt.setTaille 	#demiHD
			
			actualiser()
			m_actionEnCours = false
		)
	on btn_FR_12 changed state do
	(
			undo "Changer frame rate " on  (
					
					m_actionEnCours = true		
					
					toggleBtns_FR	 btn_FR_12
					
					m_prt.setFrameRate 12
					
					actualiser()		
					
					m_actionEnCours = false
						
				)
		)
	on btn_FR_24 changed state do
	(
			undo "Changer frame rate " on (
					m_actionEnCours = true		
					
					toggleBtns_FR	 btn_FR_12
					
					m_prt.setFrameRate 24
					
					actualiser()		
					
					m_actionEnCours = false
				)
		)
	on btn_FR_30 changed state do
	(
			undo "Changer frame rate " on (
					m_actionEnCours = true		
					
					toggleBtns_FR	 btn_FR_30
					
					m_prt.setFrameRate 30
					
					actualiser()		
					
					m_actionEnCours = false
				)
		)
	on ui_anim_debut changed val do
	(
			undo "Changer debut animation " on (		
					animationRange = interval 	val	animationRange.end
					actualiser ()
				)
		)
	on ui_anim_fin changed val do
	(
			undo "Changer fin animation " on (		
					animationRange = interval 	animationRange.start val	
					actualiser ()
				)
		)
	on btn_QUAL_brouillon changed state do
	(
			m_prt.changerQualite 	1
			/* 
			renderers.current.progressive_passLimit	=	10
			renderers.current.adaptivity_targetError	=	0
			renderers.current.denoise_blendAmount	=	.7
			*/
			actualiser()
		)
	on btn_QUAL_production changed state do
	(
			m_prt.changerQualite 	2
			/* 
			renderers.current.progressive_passLimit	=	0
			renderers.current.adaptivity_targetError	=	5.2
			renderers.current.denoise_blendAmount	=	.7
			*/
			actualiser()
		)
	on btn_QUAL_final changed state do
	(
			m_prt.changerQualite 	3
			/* 
			renderers.current.progressive_passLimit	=	0
			renderers.current.adaptivity_targetError	=	5.2
			renderers.current.denoise_blendAmount	=	.7
			*/
			actualiser()
		)
	on spn_ratio changed val do
(
-- 	renderImageAspect
-- 			renderPixelAspect = val
			renderHeight = renderWidth / val
	)
)


------------------------------------------------------------------------------
----------	Structure								 -------------------------
------------------------------------------------------------------------------
struct str_rendu (
	
		------------  Membres	----------------------------------------------------------------------------------
	public
		---- pointeurs ----
		m_dialog			= roll_rendu ,		---- le rollout ----
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
		
		--- liste des valeurs des presets ----
/* 		nbrPx_20 	= 20000000,
		nbrPx_15 	= 15000000,
		nbrPx_10 	= 10000000,
		nbrPx_5 		= 	 5000000,
		nbrPx_1 		= 	 1000000,
		nbrPx_demi = 	   500000, */
		
		m_presetsQualite =#(), 
		
		---- ecouteurs ----
		m_ecouteur_renderParams ,
		
		
		------------  Fonctions	----------------------------------------------------------------------------------
	public
	
		fn init_presetsQualite =(
			
			--- le stamp corona ----
			local renderStamp = "camera : %v |  image : %n | Tps de rendu: %pt | Passes: %pp "
			
			---- Brouillon ----
			append			m_presetsQualite		( str_presetRendu	progressive_passLimit:	10	\
																					adaptivity_targetError:	0	\
																					denoise_blendAmount:	.7	\
																					renderStamp:			renderStamp	\
																					renderstamp_use:	true )
			
			---- Production ----
			append			m_presetsQualite		( str_presetRendu	progressive_passLimit:	0	\
																					adaptivity_targetError:	5.2	\
																					denoise_blendAmount:	.7	\
																					renderStamp:			renderStamp	\
																					renderstamp_use:	true )
			
			---- Final ----
			append			m_presetsQualite		( str_presetRendu	progressive_passLimit:	0	\
																					adaptivity_targetError:	5.2	\
																					denoise_blendAmount:	.7	\
																					renderStamp:				renderStamp	\
																					renderstamp_use:		false )
		),
		
		fn changerQualite 	_idPreset =(
			
			renderers.current.progressive_passLimit	=	m_presetsQualite[ _idPreset ].progressive_passLimit
			renderers.current.adaptivity_targetError	=	m_presetsQualite[ _idPreset ].adaptivity_targetError
			renderers.current.denoise_blendAmount	=	m_presetsQualite[ _idPreset ].denoise_blendAmount
			renderers.current.renderStamp				=	m_presetsQualite[ _idPreset ].renderStamp
			renderers.current.renderstamp_use			=	m_presetsQualite[ _idPreset ].renderstamp_use
			
		),
		
		
		
		fn getRenduPixels =(
			
			local plusProche 	= 0
			
			if not m_dialog.m_actionEnCours do (
				
				--- format video ----
				if renderWidth == 1920 or renderHeight == 1080 
					then plusProche = #fullHD
				else if renderWidth == 1280 or renderHeight == 720 
					then plusProche = #HD
				else if renderWidth == 960 or renderHeight == 540 
					then plusProche = #demiHD
				
				--- format photo ----
				else (			
					local nbrPixelsCourant = renderWidth * renderHeight
	-- 	 			format "nbrPixelsCourant : %\n" nbrPixelsCourant
					local listNbrPx 	=#( 20000000, 15000000, 10000000, 5000000, 2000000 ,1000000 )
					local valMin 		= 1500000000
					for i = 1 to listNbrPx.count do (
						local nbrPix = listNbrPx[i]
						local diff = abs (nbrPix - nbrPixelsCourant)
	-- 	 				format "diff : %\n" diff
	-- 	 				format "valMin : %\n" valMin
	-- 	 				format "diff < valMin  : %\n" (diff < valMin )
						if diff < valMin do (
							valMin = diff
							plusProche = i
						)
					)
				)
				
			)
			
			plusProche
			
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
		
		
		fn setTaille		_taille 	=(
			
			local nbrPx_rendu
			
			local format_largeur
			local format_hauteur
			
			local	renderRatio = float renderWidth / float renderHeight
			
			local etaitOuvert = renderSceneDialog.isOpen() 
			
			case _taille of (
			/* 	20: 			nbrPx_rendu = nbrPx_20
				15: 			nbrPx_rendu = nbrPx_15
				10: 			nbrPx_rendu = nbrPx_10
				5: 			nbrPx_rendu = nbrPx_5
				1: 			nbrPx_rendu = nbrPx_1
				2: 			nbrPx_rendu = nbrPx_2 */
				#fullHD:		(format_largeur = 1920; format_hauteur = 1080)
				#HD:			(format_largeur = 1280; format_hauteur = 720)
				#demiHD:	(format_largeur = 960; format_hauteur = 540)
				default: 		nbrPx_rendu = _taille * 1000000
			)
			
			
			if etaitOuvert do renderSceneDialog.close()	
			
			---- si on est dans format video ----
			if nbrPx_rendu == undefined then (
				if 1920 / 1080 < renderRatio then (
					renderWidth 	= format_largeur
					renderHeight 	= format_largeur / renderRatio
				) else (
					renderWidth 	= format_hauteur * renderRatio
					renderHeight 	= format_hauteur
					
				)
				
			---- sinon on est dans format photo ----
			) else (
				renderWidth 	= floor ( sqrt ( renderRatio *  nbrPx_rendu ) )
				renderHeight 	= floor ( renderWidth / renderRatio )
			)
			
			
			if etaitOuvert do renderSceneDialog.open()
			
			[ renderWidth , renderHeight]
		),
		
		---- fenetre -----
		fn ouvrir =(			
			
			
			----- initialisation des presets de qualité -----------------
			init_presetsQualite ()
			
			
			---- creation de la fenetre ----
			/*	createDialog m_dialog  bgcolor:				col_fenetreFond 	 \
											 fgcolor:				col_fenetreTxt 	\ 
											style:				#(#style_resizing) \
											lockHeight:			true	\
											lockWidth:			true	\
											pos:					m_dialogPos*/ 
			
			createDialog m_dialog 	style:				#(#style_resizing) \
											lockHeight:			true	\
											lockWidth:			true	\
											pos:					m_dialogPos
			
			---- initialisation de la fenetre ----
			m_dialog.m_prt	 	= this
			m_dialog.initialiser ()
			
			
			
			---- initialisation des ecouteurs ----
-- 			callbacks.addScript #renderParamsChanged "mgr_rendu.getRenduPixels(); mgr_rendu.actualiser()" id:#CPages_rendu
			callbacks.addScript #renderParamsChanged "mgr_rendu.actualiser()" id:#CPages_rendu_paramChanged
			callbacks.addScript #filePostOpen "mgr_rendu.actualiser()" id:#CPages_rendu_open
			
		),
		
		fn fermer  silence:false =(		---- silence : fermer sans modifier l'état des preferences ---
			
			m_dialogPos = getDialogPos m_dialog
			
			---- fermer la fenêtre ----
			try destroydialog m_dialog catch ()
			
			---- suppression des ecouteurs ----
-- 			callbacks.removeScripts #renderParamsChanged  id:#CPages_rendu
			callbacks.removeScripts #renderParamsChanged  id:#CPages_rendu_paramChanged
			callbacks.removeScripts #renderParamsChanged  id:#CPages_rendu_open
		)
		
		------------  Evenements	----------------------------------------------------------------------------------
	
)


-- global mgr_rendu 	=	str_rendu 	()
-- mgr_rendu.ouvrir ()




