E2Lib.RegisterExtension( 'pt_constraintcore', false )

registerCallback( 'construct', function( self )

	self.data.constraints = {}
	self.data.constraint_undoenabled = false

end )

E2Lib.registerConstant( 'COLLISION_GROUP_NONE', COLLISION_GROUP_NONE )
E2Lib.registerConstant( 'COLLISION_GROUP_WORLD', COLLISION_GROUP_WORLD )

local function createConstraintUndo( self, cons )
	
	local constraint_undoenabled = self.data.constraint_undoenabled
	local ply = self.player
	
	if constraint_undoenabled then
		
		ply:AddCleanup( 'constraints', cons )
		
		local cons_type = cons:GetTable().Type or 'Unknown'
		
		undo.Create( 'expression2_' .. string.lower( cons_type ) )
		
			undo.AddEntity( cons )
			undo.SetPlayer( ply )

		undo.Finish()
		
	end
	
end

local function table2vector( tbl )

	return Vector( tbl[1] or 0, tbl[2] or ( tbl[1] or 0 ), tbl[3] or ( tbl[1] or 0 ) )

end

local function table2angle( tbl )

	return Angle( tbl[1] or 0, tbl[2] or ( tbl[1] or 0 ), tbl[3] or ( tbl[1] or 0 ) )

end

local function valid2constraint( self, ent )
	
	if ent:IsPlayer() then return false end
	if not constraint.CanConstrain( ent, 0 ) then return false end
	if not isOwner( self, ent ) then return false end

	return true

end

__e2setcost( 1 )

e2function void constraintUndoEnabled( number enabled )

	self.data.constraint_undoenabled = tobool( enabled )

end

e2function number constraintCanCreate( entity ent1, entity ent2 )

	return Either( valid2constraint( self, ent1 ) && valid2constraint( self, ent2 ), 1, 0 )

end

__e2setcost( 30 )

// constraint.AdvBallsocket
e2function number entity:advBallsocketTo( number index, entity ent2, number bone1, number bone2, vector lpos1, vector lpos2, number forcelimit, number torquelimit, vector rmin, vector rmax, vector friction, number onlyrotation, number nocollide )
	
	local ent1 = this
	
	if not valid2constraint( self, ent1 ) then return 0 end
	if not valid2constraint( self, ent2 ) then return 0 end
	if ( ent1 == ent2 ) then return 0 end
	
	local cons = constraint.AdvBallsocket( 
		ent1,
		ent2,
		bone1,
		bone2,
		table2vector( lpos1 ),
		table2vector( lpos2 ),
		forcelimit,
		torquelimit,
		rmin[1] or 0,
		rmin[2] or 0,
		rmin[3] or 0,
		rmax[1] or 0,
		rmax[2] or 0,
		rmax[3] or 0,
		friction[1] or 0,
		friction[2] or 0,
		friction[3] or 0,
		onlyrotation,
		nocollide
	)
	
	if not isentity( cons ) then return 0 end
	
	local success = Either( cons, 1, 0 )
	
	if success then
	
		self.data.constraints[ index ] = cons
		
		createConstraintUndo( self, cons )
		
	end
	
	return success

end

// constraint.Axis
e2function number entity:axisTo( number index, entity ent2, number bone1, number bone2, vector lpos1, vector lpos2, number forcelimit, number torquelimit, number friction, number nocollide, vector laxis )
	
	local ent1 = this
	
	if not valid2constraint( self, ent1 ) then return 0 end
	if not valid2constraint( self, ent2 ) then return 0 end
	if ( ent1 == ent2 ) then return 0 end
	
	local v_laxis = table2vector( laxis )
	
	if ( v_laxis:IsZero() ) then
	
		v_laxis = ( ent1:WorldToLocal( ent2:LocalToWorld( table2vector( lpos2 ) ) ) ):GetNormalized()
	
	end
	
	local cons = constraint.Axis(
		ent1,
		ent2,
		bone1,
		bone2,
		table2vector( lpos1 ),
		table2vector( lpos2 ),
		forcelimit,
		torquelimit,
		friction,
		nocollide,
		v_laxis,
		false
	)
	
	if not isentity( cons ) then return 0 end
	
	local success = Either( cons, 1, 0 )
	
	if success then
	
		self.data.constraints[ index ] = cons
		
		createConstraintUndo( self, cons )
		
	end
	
	return success
	
end

// constraint.Ballsocket
e2function number entity:ballsocketTo( number index, entity ent2, number bone1, number bone2, vector lpos, number forcelimit, number torquelimit, number nocollide )
	
	local ent1 = this
	
	if not valid2constraint( self, ent1 ) then return 0 end
	if not valid2constraint( self, ent2 ) then return 0 end
	if ( ent1 == ent2 ) then return 0 end
	
	local cons = constraint.Ballsocket(
		ent1,
		ent2,
		bone1,
		bone2, 
		table2vector( lpos ),
		forcelimit,
		torquelimit,
		nocollide
	)
	
	if not isentity( cons ) then return 0 end
	
	local success = Either( cons, 1, 0 )
	
	if success then
	
		self.data.constraints[ index ] = cons
		
		createConstraintUndo( self, cons )
		
	end
	
	return success
	
end

// constraint.Elastic
e2function number entity:elasticTo( number index, entity ent2, number bone1, number bone2, vector lpos1, vector lpos2, number constant, number damping, number rdamping, string material, number width, number stretchonly )
	
	local ent1 = this
	
	if not valid2constraint( self, ent1 ) then return 0 end
	if not valid2constraint( self, ent2 ) then return 0 end
	if ( ent1 == ent2 ) then return 0 end
	
	if ( material == '' ) then material = 'cable/cable2' end
	
	local cons = constraint.Elastic(
		ent1,
		ent2,
		bone1,
		bone2,
		table2vector( lpos1 ),
		table2vector( lpos2 ),
		constant,
		damping,
		rdamping,
		material,
		width,
		tobool( stretchonly )
	)
	
	if not isentity( cons ) then return 0 end
	
	local success = Either( cons, 1, 0 )
	
	if success then
	
		self.data.constraints[ index ] = cons
		
		createConstraintUndo( self, cons )
		
	end
	
	return success
	
end

// constraint.Keepupright
e2function number entity:keepUpright( number index, angle ang, number bone, number angularLimit )
	
	local ent = this
	
	if not valid2constraint( self, ent ) then return 0 end
	
	local cons = constraint.Keepupright( 
		ent,
		table2angle( ang ),
		bone,
		angularLimit
	)
	
	if not isentity( cons ) then return 0 end
	
	local success = Either( cons, 1, 0 )
	
	if success then
	
		self.data.constraints[ index ] = cons
		
		createConstraintUndo( self, cons )
		
	end
	
	return success

end

// constraint.Pulley
e2function number entity:pulleyTo( number index, entity ent2, number bone1, number bone2, vector lpos1, vector lpos2, vector wpos1, vector wpos2, number forcelimit, number rigid, number width, string material )
	
	local ent1 = this
	
	if not valid2constraint( self, ent1 ) then return 0 end
	if not valid2constraint( self, ent2 ) then return 0 end
	if ( ent1 == ent2 ) then return 0 end
	
	if ( material == '' ) then material = 'cable/cable2' end
	
	local cons = constraint.Pulley(
		ent1,
		ent2,
		bone1,
		bone2,
		table2vector( lpos1 ),
		table2vector( lpos2 ),
		table2vector( wpos1 ),
		table2vector( wpos2 ),
		forcelimit,
		tobool( rigid ),
		width,
		material
	)
	
	if not isentity( cons ) then return 0 end
	
	local success = Either( cons, 1, 0 )
	
	if success then
	
		self.data.constraints[ index ] = cons
		
		createConstraintUndo( self, cons )
		
	end
	
	return success
	
end

e2function number entity:ropeTo( number index, entity ent2, number bone1, number bone2, vector lpos1, vector lpos2, number length, number addlength, number forcelimit, number width, string material, number rigid )
	
	local ent1 = this
	
	if not valid2constraint( self, ent1 ) then return 0 end
	if not valid2constraint( self, ent2 ) then return 0 end
	if ( ent1 == ent2 ) then return 0 end
	
	if ( material == '' ) then material = 'cable/cable2' end
	
	local cons = constraint.Rope( 
		ent1,
		ent2,
		bone1,
		bone2,
		table2vector( lpos1 ),
		table2vector( lpos2 ),
		length,
		addlength,
		forcelimit,
		width,
		material,
		tobool( rigid )
	)
	
	if not isentity( cons ) then return 0 end
	
	local success = Either( cons, 1, 0 )
	
	if success then
	
		self.data.constraints[ index ] = cons
		
		createConstraintUndo( self, cons )
		
	end
	
	return success
	
end

e2function number entity:noCollideTo( number index, entity ent2, number bone1, number bone2  )
	
	local ent1 = this
	
	if not valid2constraint( self, ent1 ) then return 0 end
	if not valid2constraint( self, ent2 ) then return 0 end
	if ( ent1 == ent2 ) then return 0 end
	
	local cons = constraint.NoCollide(
		ent1,
		ent2,
		bone1,
		bone2
	)
	
	if not isentity( cons ) then return 0 end
	
	local success = Either( cons, 1, 0 )
	
	if success then
		
		// Hack to re-enable collisions when no-collide is removed
		cons:CallOnRemove( 'ActivateCollisions', function( ent ) ent:Input( 'EnableCollisions' ) end )
		
		self.data.constraints[ index ] = cons
		
		createConstraintUndo( self, cons )
		
	end
	
	return success
	
end

e2function number entity:sliderTo( number index, entity ent2, number bone1, number bone2, vector lpos1, vector lpos2, number width, string material )
	
	local ent1 = this
	
	if not valid2constraint( self, ent1 ) then return 0 end
	if not valid2constraint( self, ent2 ) then return 0 end
	if ( ent1 == ent2 ) then return 0 end
	
	if ( material == '' ) then material = 'cable/cable2' end
	
	local cons = constraint.Slider( 
		ent1,
		ent2,
		bone1,
		bone2,
		table2vector( lpos1 ),
		table2vector( lpos2 ),
		width,
		material
	)
	
	if not isentity( cons ) then return 0 end
	
	local success = Either( cons, 1, 0 )
	
	if success then

		self.data.constraints[ index ] = cons
		
		createConstraintUndo( self, cons )
		
	end
	
	return success
	
end

e2function number entity:weldTo( number index, entity ent2, number bone1, number bone2, number forcelimit, number nocollide )
	
	local ent1 = this
	
	if not valid2constraint( self, ent1 ) then return 0 end
	if not valid2constraint( self, ent2 ) then return 0 end
	if ( ent1 == ent2 ) then return 0 end
	
	local cons = constraint.Weld( 
		ent1,
		ent2,
		bone1,
		bone2,
		forcelimit,
		tobool( nocollide ),
		false
	)
	
	if not isentity( cons ) then return 0 end
	
	local success = Either( cons, 1, 0 )
	
	if success then

		self.data.constraints[ index ] = cons
		
		createConstraintUndo( self, cons )
		
	end
	
	return success

end

__e2setcost( 5 )

e2function void entity:setCollisionGroup( number group )

	if not ( this && this:IsValid() ) then return end
	if not isOwner( self, this ) then return end
	
	this:SetCollisionGroup( group )
	
end

__e2setcost( 1 )

e2function number entity:removeAllConstraints()

	if not ( this && this:IsValid() ) then return 0 end
	if not isOwner( self, this ) then return end
	
	local bool, count = constraint.RemoveAll( this )
	
	return count
	
end

e2function number entity:removeConstraints( string type )

	if not ( this && this:IsValid() ) then return 0 end
	if not isOwner( self, this ) then return end
	
	local bool, count = constraint.RemoveConstraints( this, type )
	
	return count
	
end

e2function number entity:removeConstraints( entity ent2 )

	if not ( this && this:IsValid() ) then return 0 end
	if not ( ent2 && ent2:IsValid() ) then return 0 end
	if not isOwner( self, this ) then return end
	if not isOwner( self, ent2 ) then return end
	
	local count = 0
	
	for k, v in pairs( constraint.GetTable( this ) ) do
	
		if ( v.Ent2 == ent2 ) || ( v.Ent1 == ent2 ) then

			v.Constraint:Remove()
		
			count = count + 1
		
		end
	
	end
	
	return count

end

e2function number entity:removeConstraints( string type, entity ent2 )

	if not ( this && this:IsValid() ) then return 0 end
	if not ( ent2 && ent2:IsValid() ) then return 0 end
	if not isOwner( self, this ) then return end
	if not isOwner( self, ent2 ) then return end
	
	local count = 0
	
	for k, v in pairs( constraint.GetTable( this ) ) do
	
		if ( ( v.Ent2 == ent2 ) || ( v.Ent1 == ent2 ) ) && ( v.Type == type ) then

			v.Constraint:Remove()
		
			count = count + 1
		
		end
	
	end
	
	return count

end

e2function void removeConstraint( number index ) 

	local cons = self.data.constraints[ index ]
	
	if cons && cons:IsValid() then
	
		cons:Remove()
	
	end
	
end

e2function void setConstraintFire( number index, string key, number value )

	local cons = self.data.constraints[ index ]

	if cons && cons:IsValid() then

		cons:Fire( key, value )
		
	end

end

e2function void setConstraintInput( number index, string input )

	local cons = self.data.constraints[ index ]

	if cons && cons:IsValid() then

		cons:Input( input )
		
	end

end

local function getType( obj )

	if isstring( obj ) then return 's' end
	if isnumber( obj ) then return 'n' end
	if isentity( obj ) then return 'e' end
	if isbool( obj ) then return 'n' end
	if isvector( obj ) then return 'v' end
	
end

local DEFAULT = {
	n = {},
	ntypes = {},
	s = {},
	stypes = {},
	size = 0
}

__e2setcost( 5 )

e2function table getConstraintTable( number index )

	local cons = self.data.constraints[ index ]
	
	local return_tbl = table.Copy( DEFAULT )
	
	if cons && cons:IsValid() then
		
		for k, v in pairs( cons:GetTable() ) do
			
			if not getType( v ) then continue end
			
			return_tbl.ntypes[ tostring( k ) ] = getType( v )
			return_tbl.n[ tostring( k ) ] = tostring( v )
			return_tbl.size = return_tbl.size + 1
		
		end
		
	end
	
	return return_tbl
	
end

__e2setcost( 20 )

e2function table entity:getConstraintsTable()

	if not ( this && this:IsValid() ) then return DEFAULT end
	if not constraint.HasConstraints( this ) then return DEFAULT end
	
	local return_tbl = table.Copy( DEFAULT )

	for k, v in pairs( constraint.GetTable( this ) ) do
		
		if not istable( v ) then continue end
		
		local cons = table.Copy( DEFAULT )
		
		for k, v in pairs( v ) do
			
			if not getType( v ) then continue end
			
			cons.s[ tostring( k ) ] = v
			cons.stypes[ tostring( k ) ] = getType( v )

			cons.size = cons.size + 1
			
		end
		
		return_tbl.ntypes[ k ] = 't'
		return_tbl.n[ k ] = cons
		return_tbl.size = return_tbl.size + 1
		
	end

	return return_tbl
	
end
