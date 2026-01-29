<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use Illuminate\Http\Request;
use App\Models\Category;

class CategoryController extends Controller
{
    public function index(){
        return Category::with('parent')->latest()->get();
    }

    public function store(Request $request){
        $request->validate([
            'name' => 'required|string|max:255',
            'parent_id' => 'nullable|exists:categories,id'
        ]);

        $category=Category::create($request->all());
        logActivity('Category Created',$category->name);

        return response()->json(['message'=>'Category added']);
    }

    public function update(Request $request, $id){
        $request->validate([
            'name' => 'required|string|max:255',
            'parent_id' => 'nullable|exists:categories,id'
        ]);

        $category=Category::findOrFail($id);

        $category->update($request->all());
        logActivity('Category Updated', $category->name);

        return response()->json(['message'=>'Category updated']);
    }

    public function destroy($id){
        $category=Category::findOrFail($id);
        $category->delete();

        logActivity('Category Deleted', $category->name);

        return response()->json(['message'=>'Category deleted']);
    }
}
