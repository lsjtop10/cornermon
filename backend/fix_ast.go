package main

import (
	"bytes"
	"fmt"
	"go/ast"
	"go/format"
	"go/parser"
	"go/token"
	"io/fs"
	"os"
	"path/filepath"
	"strings"

	"golang.org/x/tools/go/ast/astutil"
)

func main() {
	fset := token.NewFileSet()

	err := filepath.WalkDir(".", func(path string, d fs.DirEntry, err error) error {
		if err != nil {
			return err
		}
		if d.IsDir() {
			if path == "vendor" || path == ".git" {
				return filepath.SkipDir
			}
			return nil
		}
		if !strings.HasSuffix(path, ".go") {
			return nil
		}

		if strings.HasPrefix(path, "internal/domain") && !strings.HasSuffix(path, "_test.go") {
			return nil
		}

		file, err := parser.ParseFile(fset, path, nil, parser.ParseComments)
		if err != nil {
			return nil
		}

		changed := false

		astutil.Apply(file, func(c *astutil.Cursor) bool {
			n := c.Node()

			// Replace UnaryExpr `&domain.X{...}`
			if un, ok := n.(*ast.UnaryExpr); ok && un.Op == token.AND {
				if comp, ok := un.X.(*ast.CompositeLit); ok {
					if selExpr, ok := comp.Type.(*ast.SelectorExpr); ok {
						if ident, ok := selExpr.X.(*ast.Ident); ok && ident.Name == "domain" {
							structName := selExpr.Sel.Name
							if !strings.HasSuffix(structName, "Props") {
								selExpr.Sel.Name = structName + "Props"

								callExpr := &ast.CallExpr{
									Fun: &ast.SelectorExpr{
										X:   &ast.Ident{Name: "domain"},
										Sel: &ast.Ident{Name: "New" + structName + "FromProps"},
									},
									Args: []ast.Expr{comp},
								}
								c.Replace(callExpr)
								changed = true
								return false // skip children
							}
						}
					}
				}
			}

			// Replace CompositeLit `domain.X{...}`
			if comp, ok := n.(*ast.CompositeLit); ok {
				if selExpr, ok := comp.Type.(*ast.SelectorExpr); ok {
					if ident, ok := selExpr.X.(*ast.Ident); ok && ident.Name == "domain" {
						structName := selExpr.Sel.Name
						if !strings.HasSuffix(structName, "Props") {
							selExpr.Sel.Name = structName + "Props"

							callExpr := &ast.CallExpr{
								Fun: &ast.SelectorExpr{
									X:   &ast.Ident{Name: "domain"},
									Sel: &ast.Ident{Name: "New" + structName + "ValFromProps"},
								},
								Args: []ast.Expr{comp},
							}
							c.Replace(callExpr)
							changed = true
							return false // skip children
						}
					}
				}
			}

			return true
		}, nil)

		if changed {
			var buf bytes.Buffer
			if err := format.Node(&buf, fset, file); err != nil {
				fmt.Println("Error formatting:", path, err)
			} else {
				os.WriteFile(path, buf.Bytes(), 0644)
			}
		}
		return nil
	})

	if err != nil {
		fmt.Println("Error:", err)
	}
}
