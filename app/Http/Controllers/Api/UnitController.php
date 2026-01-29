<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use Illuminate\Http\Request;
use App\Models\Unit;

class UnitController extends Controller
{
    public function index(){
        return response()->json(['data'=>Unit::latest()->get()]);
    }

    public function store(Request $request){
        $request->validate([
            'name'=>'required|unique:units,name'
        ]);

        $unit=Unit::create($request->all());

        logActivity('Unit Created',$unit->name);
        return response()->json(['message'=>'Unit created']);
    }

    public function update(Request $request,$id){
        $request->validate([
            'name'=>'required|unique:units,name'
        ]);

        $unit=Unit::findOrFail($id);
        $unit->update($request->all());

        logActivity('Unit Updated',$unit->name);
        return response()->json(['message'=>'unit updated']);
    }

    public function destroy($id){
        $unit=Unit::findOrFail($id);
        $unit->delete();
        
        logActivity('Unit Deleted',$unit->name);
        return response()->json(['message'=>'unit deleted']);
    }
}
